import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../providers/clothing_item_providers.dart';
import 'edit_outfit_form.dart';
import 'clothing_item_thumbnail.dart';

/// Calendar view for displaying outfits in a monthly format
class OutfitCalendarView extends ConsumerStatefulWidget {
  final List<Outfit> outfits;

  const OutfitCalendarView({super.key, required this.outfits});

  @override
  ConsumerState<OutfitCalendarView> createState() => _OutfitCalendarViewState();
}

/// Helper class to hold calendar calculation data
class _CalendarData {
  final int daysInMonth;
  final int firstWeekday;
  final int weeks;

  const _CalendarData({
    required this.daysInMonth,
    required this.firstWeekday,
    required this.weeks,
  });
}

class _OutfitCalendarViewState extends ConsumerState<OutfitCalendarView> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _selectedDate = now;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.outfits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No outfits logged yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Log some outfits to see them in the calendar view',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Month navigation
        _buildMonthNavigation(),
        
        // Calendar grid
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            icon: Icons.chevron_left,
            onPressed: _goToPreviousMonth,
          ),
          _buildMonthHeader(),
          _buildNavigationButton(
            icon: Icons.chevron_right,
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  Widget _buildMonthHeader() {
    return Column(
      children: [
        Text(
          '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: _goToToday,
          child: const Text('Today', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _focusedDate = DateTime(now.year, now.month, 1);
      _selectedDate = now;
    });
  }

  Widget _buildCalendarGrid() {
    final calendarData = _calculateCalendarData();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: calendarData.weeks + 1, // +1 for weekday headers
      itemBuilder: (context, weekIndex) {
        if (weekIndex == 0) {
          return _buildWeekdayHeaders();
        }
        
        final actualWeekIndex = weekIndex - 1;
        final startCell = actualWeekIndex * 7;
        
        return _buildWeekRow(
          startCell: startCell,
          firstWeekday: calendarData.firstWeekday,
          daysInMonth: calendarData.daysInMonth,
        );
      },
    );
  }

  _CalendarData _calculateCalendarData() {
    final daysInMonth = _getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final totalCells = firstWeekday - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();
    
    return _CalendarData(
      daysInMonth: daysInMonth,
      firstWeekday: firstWeekday,
      weeks: weeks,
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      children: weekdays.map(_buildWeekdayHeader).toList(),
    );
  }

  Widget _buildWeekdayHeader(String day) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          day,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekRow({
    required int startCell,
    required int firstWeekday,
    required int daysInMonth,
  }) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final cellData = _calculateCellData(dayIndex, startCell, firstWeekday, daysInMonth);
        return Expanded(child: cellData);
      }),
    );
  }

  Widget _calculateCellData(int dayIndex, int startCell, int firstWeekday, int daysInMonth) {
    final cellIndex = startCell + dayIndex;
    final dayOffset = cellIndex - (firstWeekday - 1);
    
    if (dayOffset < 0 || dayOffset >= daysInMonth) {
      return const SizedBox(height: 60);
    }
    
    final day = dayOffset + 1;
    final date = DateTime(_focusedDate.year, _focusedDate.month, day);
    final hasOutfits = _hasOutfitsOnDate(date);
    
    return _buildDayCell(date, day, hasOutfits);
  }

    Widget _buildDayCell(DateTime date, int day, bool hasOutfits) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        _showOutfitsForDate(date);
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getDayCellColor(isSelected, hasOutfits),
          border: Border.all(
            color: _getDayCellBorderColor(isToday),
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            _buildDayNumber(day, isSelected),
            if (hasOutfits) _buildOutfitDots(date, isSelected),
          ],
        ),
      ),
    );
  }

  Color? _getDayCellColor(bool isSelected, bool hasOutfits) {
    if (isSelected) return Theme.of(context).colorScheme.primary;
    if (hasOutfits) return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
    return null;
  }

  Color _getDayCellBorderColor(bool isToday) {
    return isToday ? Theme.of(context).colorScheme.primary : Colors.grey.shade300;
  }

  Widget _buildDayNumber(int day, bool isSelected) {
    return Positioned(
      top: 4,
      left: 4,
      child: Text(
        day.toString(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        ),
      ),
    );
  }

  Widget _buildOutfitDots(DateTime date, bool isSelected) {
    final outfitCount = _getOutfitCountForDate(date).clamp(0, 5);
    
    return Positioned(
      bottom: 4,
      right: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          outfitCount,
          (index) => Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(right: index < outfitCount - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  bool _hasOutfitsOnDate(DateTime date) {
    return widget.outfits.any((outfit) => _isSameDay(outfit.date, date));
  }

  int _getOutfitCountForDate(DateTime date) {
    return widget.outfits.where((outfit) => _isSameDay(outfit.date, date)).length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final outfitDate = DateTime(date.year, date.month, date.day);

    if (outfitDate == today) {
      return 'Today';
    } else if (outfitDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _editOutfit(BuildContext context, Outfit outfit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditOutfitForm(outfit: outfit),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Outfit outfit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Outfit'),
          content: Text('Are you sure you want to delete the outfit from ${_formatDate(outfit.date)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // TODO: Implement delete functionality when outfit providers are available
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showOutfitsForDate(DateTime date) {
    final outfitsForDate = widget.outfits
        .where((outfit) => _isSameDay(outfit.date, date))
        .toList();
    
    if (outfitsForDate.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildOutfitsBottomSheet(date, outfitsForDate),
    );
  }

  Widget _buildOutfitsBottomSheet(DateTime date, List<Outfit> outfits) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                                         Text(
                       _getOutfitsTitle(date),
                       style: const TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // Outfits list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final outfit = outfits[index];
                    return _buildOutfitCard(context, outfit);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOutfitCard(BuildContext context, Outfit outfit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with time and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Time (if multiple outfits on same day)
                if (outfit.date.hour != 0 || outfit.date.minute != 0)
                  Text(
                    '${outfit.date.hour.toString().padLeft(2, '0')}:${outfit.date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editOutfit(context, outfit);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, outfit);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Clothing items
            FutureBuilder<List<ClothingItem>>(
              future: _getClothingItemsForOutfit(outfit),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error loading items: ${snapshot.error}');
                }

                final clothingItems = snapshot.data ?? [];
                if (clothingItems.isEmpty) {
                  return const Text(
                    'No clothing items found',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  );
                }

                return Column(
                  children: clothingItems.map((item) => _buildClothingItemTile(item)).toList(),
                );
              },
            ),

            // Notes
            if (outfit.notes != null && outfit.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  outfit.notes!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItemTile(ClothingItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClothingItemThumbnail(
        item: item,
        size: 24,
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        '${item.category}${item.subcategory != null ? ' • ${item.subcategory}' : ''}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }

  Future<List<ClothingItem>> _getClothingItemsForOutfit(Outfit outfit) async {
    final clothingItemsAsync = ref.read(activeClothingItemsProvider.future);
    final clothingItems = await clothingItemsAsync;
    
    return clothingItems
        .where((item) => outfit.clothingItemIds.contains(item.id))
        .toList();
  }



  String _getOutfitsTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final outfitDate = DateTime(date.year, date.month, date.day);

    if (outfitDate == today) {
      return 'Outfits today';
    } else if (outfitDate == yesterday) {
      return 'Outfits yesterday';
    } else {
      return 'Outfits on ${date.day}/${date.month}/${date.year}';
    }
  }
}
