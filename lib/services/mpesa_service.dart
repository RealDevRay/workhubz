import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';

class MpesaService {
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  MpesaService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.darajaBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  Future<String?> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    final consumerKey = const String.fromEnvironment('MPESA_CONSUMER_KEY');
    final consumerSecret = const String.fromEnvironment(
      'MPESA_CONSUMER_SECRET',
    );
    if (consumerKey.isEmpty || consumerSecret.isEmpty) {
      if (kDebugMode)
        debugPrint(
          'MPESA: Consumer key or secret not set. Use --dart-define=MPESA_CONSUMER_KEY=... --dart-define=MPESA_CONSUMER_SECRET=... or the build script.',
        );
      return null;
    }

    final auth = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));

    try {
      final response = await _dio.get(
        ApiEndpoints.darajaOauth,
        options: Options(headers: {'Authorization': 'Basic $auth'}),
      );
      _accessToken = response.data['access_token'];
      final expiresIn = response.data['expires_in'] as int? ?? 3599;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
      return _accessToken;
    } catch (e) {
      if (kDebugMode) debugPrint('MPESA OAuth error: $e');
      return null;
    }
  }

  Future<MpesaPaymentResult> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDescription,
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      return MpesaPaymentResult(
        success: false,
        errorMessage:
            'Failed to authenticate with M-Pesa. Check MPESA_CONSUMER_KEY/SECRET (via --dart-define or build script) and network.',
      );
    }

    try {
      final timestamp = _generateTimestamp();
      final password = _generatePassword(timestamp);
      final normalizedPhone = _normalizePhone(phoneNumber);

      final response = await _dio.post(
        ApiEndpoints.darajaStkPush,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'BusinessShortCode': AppConstants.mpesaShortcode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toInt(),
          'PartyA': normalizedPhone,
          'PartyB': AppConstants.mpesaShortcode,
          'PhoneNumber': normalizedPhone,
          'CallBackURL': AppConstants.mpesaCallbackUrl,
          'AccountReference': accountReference,
          'TransactionDesc': transactionDescription,
        },
      );

      if (response.data['ResponseCode'] == '0') {
        return MpesaPaymentResult(
          success: true,
          checkoutRequestId: response.data['CheckoutRequestID'],
          customerMessage: response.data['CustomerMessage'],
        );
      } else {
        return MpesaPaymentResult(
          success: false,
          errorMessage: response.data['CustomerMessage'] ?? 'Payment failed',
        );
      }
    } on DioException catch (e) {
      return MpesaPaymentResult(
        success: false,
        errorMessage: e.message ?? 'Network error',
      );
    } catch (e) {
      return MpesaPaymentResult(
        success: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  Future<MpesaPaymentResult> queryPaymentStatus(
    String checkoutRequestId,
  ) async {
    final token = await _getAccessToken();
    if (token == null) {
      return MpesaPaymentResult(
        success: false,
        errorMessage:
            'Failed to authenticate with M-Pesa. Check MPESA_CONSUMER_KEY/SECRET (via --dart-define or build script) and network.',
      );
    }

    try {
      final timestamp = _generateTimestamp();
      final password = _generatePassword(timestamp);

      final response = await _dio.post(
        ApiEndpoints.darajaStkQuery,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          'BusinessShortCode': AppConstants.mpesaShortcode,
          'Password': password,
          'Timestamp': timestamp,
          'CheckoutRequestID': checkoutRequestId,
        },
      );

      final resultCode = response.data['ResultCode'];
      if (resultCode == '0') {
        return MpesaPaymentResult(
          success: true,
          resultCode: 0,
          resultDesc: response.data['ResultDesc'],
          checkoutRequestId: checkoutRequestId,
        );
      } else if (resultCode == '1037') {
        return MpesaPaymentResult(
          success: false,
          errorMessage: 'Still processing...',
          checkoutRequestId: checkoutRequestId,
        );
      } else {
        return MpesaPaymentResult(
          success: false,
          errorMessage: response.data['ResultDesc'] ?? 'Payment failed',
          resultCode: int.tryParse(resultCode ?? '-1'),
        );
      }
    } catch (e) {
      return MpesaPaymentResult(
        success: false,
        errorMessage: e.toString(),
        checkoutRequestId: checkoutRequestId,
      );
    }
  }

  String _normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.startsWith('+')) normalized = normalized.substring(1);
    if (normalized.startsWith('0'))
      normalized = '254${normalized.substring(1)}';
    return normalized;
  }

  String _generateTimestamp() {
    final now = DateTime.now();
    return '${now.year}${_pad(now.month)}${_pad(now.day)}${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  }

  String _generatePassword(String timestamp) {
    final data =
        '${AppConstants.mpesaShortcode}${AppConstants.mpesaPasskey}$timestamp';
    return base64Encode(utf8.encode(data));
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}

class MpesaPaymentResult {
  final bool success;
  final String? checkoutRequestId;
  final String? customerMessage;
  final int? resultCode;
  final String? resultDesc;
  final String? errorMessage;

  MpesaPaymentResult({
    required this.success,
    this.checkoutRequestId,
    this.customerMessage,
    this.resultCode,
    this.resultDesc,
    this.errorMessage,
  });
}
