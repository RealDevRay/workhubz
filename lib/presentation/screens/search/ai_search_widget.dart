import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/groq_service.dart';

final aiSearchLoadingProvider = StateProvider<bool>((ref) => false);

class AiSearchWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSearchExtracted;

  const AiSearchWidget({super.key, required this.onSearchExtracted});

  @override
  ConsumerState<AiSearchWidget> createState() => _AiSearchWidgetState();
}

class _AiSearchWidgetState extends ConsumerState<AiSearchWidget> {
  final _controller = TextEditingController();
  final _groqService = GroqService();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(aiSearchLoadingProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'AI Smart Search',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Try: Find me a cheap quiet place in Westlands with parking',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Describe your ideal workspace...',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _performAiSearch(),
                ),
              ),
              const SizedBox(width: 8),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: _performAiSearch,
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _performAiSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    ref.read(aiSearchLoadingProvider.notifier).state = true;

    final result = await _groqService.parseSearchQuery(query);

    ref.read(aiSearchLoadingProvider.notifier).state = false;

    if (result.data != null) {
      widget.onSearchExtracted(result.data!);
      _controller.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'AI search failed')),
        );
      }
    }
  }
}
