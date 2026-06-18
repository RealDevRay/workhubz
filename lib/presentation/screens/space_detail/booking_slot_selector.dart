import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';

class BookingSlotSelector extends StatefulWidget {
  final double hourlyRate;
  final double? halfDayRate;
  final double? fullDayRate;
  final Function(BookingSlot) onSlotSelected;

  const BookingSlotSelector({
    super.key,
    required this.hourlyRate,
    this.halfDayRate,
    this.fullDayRate,
    required this.onSlotSelected,
  });

  @override
  State<BookingSlotSelector> createState() => _BookingSlotSelectorState();
}

class _BookingSlotSelectorState extends State<BookingSlotSelector> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedDurationType = 'hourly'; // hourly, halfDay, fullDay

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Calendar
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Duration Type Selection
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Booking Duration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildDurationOption(
                  'Hourly',
                  'hourly',
                  'KSh ${widget.hourlyRate.toInt()}/hour',
                ),
                const SizedBox(height: 8),
                if (widget.halfDayRate != null)
                  _buildDurationOption(
                    'Half Day (4-5 hours)',
                    'halfDay',
                    'KSh ${widget.halfDayRate?.toInt() ?? 0}',
                  ),
                if (widget.halfDayRate != null) const SizedBox(height: 8),
                if (widget.fullDayRate != null)
                  _buildDurationOption(
                    'Full Day (8+ hours)',
                    'fullDay',
                    'KSh ${widget.fullDayRate?.toInt() ?? 0}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Time Selection (only for hourly)
          if (_selectedDurationType == 'hourly') ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectStartTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _startTime?.format(context) ?? 'Pick time',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectEndTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _endTime?.format(context) ?? 'Pick time',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Price Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${_formatDate(_selectedDay)}'),
                  Text('Duration: ${_getDurationText()}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'KSh ${_calculateTotal().toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canConfirm() ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(String label, String value, String price) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDurationType = value);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedDurationType == value
                ? AppColors.primary
                : Colors.grey[300]!,
            width: _selectedDurationType == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _selectedDurationType == value
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDurationText() {
    if (_selectedDurationType == 'hourly') {
      if (_startTime != null && _endTime != null) {
        return '${_startTime!.format(context)} - ${_endTime!.format(context)}';
      }
      return 'Select times';
    } else if (_selectedDurationType == 'halfDay') {
      return '4-5 hours';
    } else {
      return '8+ hours';
    }
  }

  double _calculateTotal() {
    if (_selectedDurationType == 'hourly') {
      if (_startTime != null && _endTime != null) {
        final hours = _calculateHoursDifference(_startTime!, _endTime!);
        return widget.hourlyRate * hours;
      }
      return 0;
    } else if (_selectedDurationType == 'halfDay') {
      return widget.halfDayRate ?? 0;
    } else {
      return widget.fullDayRate ?? 0;
    }
  }

  int _calculateHoursDifference(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return ((endMinutes - startMinutes) / 60).ceil();
  }

  bool _canConfirm() {
    if (_selectedDurationType == 'hourly') {
      return _startTime != null && _endTime != null;
    }
    return true;
  }

  void _confirmBooking() {
    final slot = BookingSlot(
      date: _selectedDay,
      startTime: _startTime,
      endTime: _endTime,
      durationType: _selectedDurationType,
      totalAmount: _calculateTotal(),
    );
    widget.onSlotSelected(slot);
  }
}

class BookingSlot {
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String durationType;
  final double totalAmount;

  BookingSlot({
    required this.date,
    this.startTime,
    this.endTime,
    required this.durationType,
    required this.totalAmount,
  });
}
