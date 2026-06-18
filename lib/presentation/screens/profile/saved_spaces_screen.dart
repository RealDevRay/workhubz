import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/space_providers.dart';

class SavedSpacesScreen extends ConsumerWidget {
  const SavedSpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedSpacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Spaces')),
      body: savedIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Saved Spaces',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Center(child: Text('You have ${savedIds.length} saved spaces.')),
    );
  }
}
