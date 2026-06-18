class ApiEndpoints {
  static const String baseUrl = 'https://api.workspacefinder.co.ke';
  static const String spacesEndpoint = '/spaces';
  static const String bookingsEndpoint = '/bookings';
  static const String reviewsEndpoint = '/reviews';
  static const String usersEndpoint = '/users';
  static const String paymentsEndpoint = '/payments';

  static const String darajaBaseUrl = 'https://sandbox.safaricom.co.ke';
  static const String darajaOauth =
      '/oauth/v1/generate?grant_type=client_credentials';
  static const String darajaStkPush = '/mpesa/stkpush/v1/processrequest';
  static const String darajaStkQuery = '/mpesa/stkpushquery/v1/query';

  static const String googleMapsDistanceMatrix =
      'https://maps.googleapis.com/maps/api/distancematrix/json';

  static const String googlePlacesApi =
      'https://maps.googleapis.com/maps/api/place';

  static String spaceDetail(String id) => '/spaces/$id';
  static String spaceReviews(String id) => '/spaces/$id/reviews';
  static String userBookings(String userId) => '/users/$userId/bookings';
}
