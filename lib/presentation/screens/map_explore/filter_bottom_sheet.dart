import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/nairobi_neighborhoods.dart';
import '../../../core/theme/app_colors.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final Function(FilterOptions) onApply;
  final FilterOptions? initialFilters;

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late RangeValues priceRange;
  late Set<String> selectedAmenities;
  late Set<String> selectedNeighborhoods;
  late String selectedSort;
  late bool openNow;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters ?? FilterOptions();
    priceRange = RangeValues(filters.minPrice, filters.maxPrice);
    selectedAmenities = Set.from(filters.amenities);
    selectedNeighborhoods = Set.from(filters.neighborhoods);
    selectedSort = filters.sortBy;
    openNow = filters.openNow;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Range
              _buildSectionTitle('Price Range (KSh/hr)'),
              RangeSlider(
                values: priceRange,
                min: 0,
                max: 1000,
                divisions: 100,
                onChanged: (value) {
                  setState(() => priceRange = value);
                },
                labels: RangeLabels(
                  'KSh ${priceRange.start.toInt()}',
                  'KSh ${priceRange.end.toInt()}',
                ),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // Amenities
              _buildSectionTitle('Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Wi-Fi',
                      'Power Outlets',
                      'Quiet',
                      '24-Hour',
                      'Food Available',
                      'Parking',
                      'Power Backup',
                    ].map((amenity) {
                      final isSelected = selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedAmenities.add(amenity);
                            } else {
                              selectedAmenities.remove(amenity);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary.withValues(alpha: 0.3),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Neighborhoods
              _buildSectionTitle('Neighborhoods'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NairobiNeighborhood.values.map((neighborhoodEnum) {
                  final neighborhood = neighborhoodEnum.displayName;
                  final isSelected = selectedNeighborhoods.contains(
                    neighborhood,
                  );
                  return FilterChip(
                    label: Text(neighborhood),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedNeighborhoods.add(neighborhood);
                        } else {
                          selectedNeighborhoods.remove(neighborhood);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Opening Time
              _buildSectionTitle('Opening Time'),
              CheckboxListTile(
                title: const Text('Open Now'),
                value: openNow,
                onChanged: (value) {
                  setState(() => openNow = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // Sort By
              _buildSectionTitle('Sort By'),
              DropdownButton<String>(
                value: selectedSort,
                isExpanded: true,
                items: ['Nearest', 'Cheapest', 'Highest Rated']
                    .map(
                      (sort) =>
                          DropdownMenuItem(value: sort, child: Text(sort)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSort = value ?? 'Nearest');
                },
              ),
              const SizedBox(height: 32),

              // Apply Button
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _applyFilters() {
    final filters = FilterOptions(
      minPrice: priceRange.start,
      maxPrice: priceRange.end,
      amenities: selectedAmenities.toList(),
      neighborhoods: selectedNeighborhoods.toList(),
      sortBy: selectedSort,
      openNow: openNow,
    );
    widget.onApply(filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      priceRange = const RangeValues(0, 1000);
      selectedAmenities.clear();
      selectedNeighborhoods.clear();
      selectedSort = 'Nearest';
      openNow = false;
    });
  }
}

class FilterOptions {
  final double minPrice;
  final double maxPrice;
  final List<String> amenities;
  final List<String> neighborhoods;
  final String sortBy;
  final bool openNow;

  FilterOptions({
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.amenities = const [],
    this.neighborhoods = const [],
    this.sortBy = 'Nearest',
    this.openNow = false,
  });
}
