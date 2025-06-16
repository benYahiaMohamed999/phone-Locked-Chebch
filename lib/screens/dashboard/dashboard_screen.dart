// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/repair_service.dart';
import '../../models/repair_transaction.dart';
import '../../models/repair_part.dart';

import '../../l10n/app_localizations.dart';

import '../../widgets/parts_modal_bottom_sheet.dart';
import '../../widgets/unpaid_parts_modal_bottom_sheet.dart';
import '../repair/add_repair_screen.dart';
import '../repair/edit_repair_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final RepairService _repairService = RepairService();
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _userId;
  bool _isFilterExpanded = false;
  late List<String> _filterOptions;
  late String _selectedFilter;
  late AppLocalizations localizations;
  String? _unpaidPartsSearchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentUser();

    // Set default date range to today
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = AppLocalizations.of(context)!;
    _filterOptions = [
      localizations.today,
      localizations.yesterday,
      localizations.thisWeek,
      localizations.thisMonth,
      localizations.customRange
    ];
    _selectedFilter = localizations.today;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  void _applyDateFilter(String filter) {
    final now = DateTime.now();

    setState(() {
      _selectedFilter = filter;

      switch (filter) {
        case String f when f == localizations.today:
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case String f when f == localizations.yesterday:
          final yesterday = now.subtract(const Duration(days: 1));
          _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
          _endDate = DateTime(
              yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
          break;
        case String f when f == localizations.thisWeek:
          // Find first day of week (Monday)
          final weekDay = now.weekday;
          final firstDayOfWeek = now.subtract(Duration(days: weekDay - 1));
          _startDate = DateTime(
              firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case String f when f == localizations.thisMonth:
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case String f when f == localizations.customRange:
          _selectCustomDateRange();
          break;
      }

      // Hide filter panel after selection
      if (filter != localizations.customRange) {
        _isFilterExpanded = false;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    try {
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final ThemeData theme = Theme.of(context);
      final bool isSmallScreen = mediaQuery.size.width < 600;

      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: _startDate != null && _endDate != null
            ? DateTimeRange(start: _startDate!, end: _endDate!)
            : null,
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.primary,
                onPrimary: theme.colorScheme.onPrimary,
                surface: theme.colorScheme.surface,
                onSurface: theme.colorScheme.onSurface,
                secondary: theme.colorScheme.secondary,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
              dialogTheme: DialogTheme(
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: theme.colorScheme.surface,
                headerBackgroundColor: theme.colorScheme.primary,
                headerForegroundColor: theme.colorScheme.onPrimary,
                dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return null;
                }),
                dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.onPrimary;
                  }
                  return null;
                }),
                todayBackgroundColor:
                    MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return theme.colorScheme.primary.withOpacity(0.1);
                }),
                todayForegroundColor:
                    MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return theme.colorScheme.onPrimary;
                  }
                  return theme.colorScheme.primary;
                }),
                rangePickerBackgroundColor:
                    theme.colorScheme.primary.withOpacity(0.1),
                rangePickerShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                rangeSelectionBackgroundColor:
                    theme.colorScheme.primary.withOpacity(0.2),
                rangeSelectionOverlayColor: MaterialStateProperty.all(
                  theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
            ),
            child: MediaQuery(
              // Make date picker adapt to screen size
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: isSmallScreen ? 0.9 : 1.0,
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            ),
          );
        },
      );

      if (picked != null) {
        setState(() {
          _startDate = DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          );
          _endDate = DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          );
          _isFilterExpanded = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorWithMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final theme = Theme.of(context);
    // Detect screen size for responsive UI
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 1200;
    final isSmallScreen = screenWidth <= 800;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    // Adjust constraints for landscape orientation on small/medium devices
    final maxContentWidth = isLandscape && !isLargeScreen
        ? screenWidth * 0.95
        : isLargeScreen
            ? 1200.0
            : double.infinity;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          localizations.dashboard,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt,
              color: theme.colorScheme.onPrimary,
              size: isSmallScreen ? 22 : 24,
            ),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: theme.colorScheme.onPrimary,
              size: isSmallScreen ? 22 : 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxContentWidth,
          ),
          child: Column(
            children: [
              _buildDateRangeSelector(localizations),
              Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: isSmallScreen,
                  indicatorWeight: 3,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                  ),
                  tabs: [
                    Tab(
                      text: localizations.unpaidRepairs,
                      icon: Icon(
                        Icons.pending_outlined,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    Tab(
                      text: localizations.paidRepairs,
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    Tab(
                      text: localizations.repairParts,
                      icon: Icon(
                        Icons.build_outlined,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  ],
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRepairsList(false, localizations),
                    _buildRepairsList(true, localizations),
                    _buildUnpaidPartsList(localizations),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddRepairScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tooltip: localizations.addRepair,
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
          size: isSmallScreen ? 24 : 28,
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations localizations) {
    final theme = Theme.of(context);
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isSmallScreen = screenWidth < 600;

    String _getDateRangeText() {
      if (_startDate == null || _endDate == null) {
        return localizations.selectRange;
      }

      final startDay = _startDate!.day.toString().padLeft(2, '0');
      final startMonth = _startDate!.month.toString().padLeft(2, '0');
      final endDay = _endDate!.day.toString().padLeft(2, '0');
      final endMonth = _endDate!.month.toString().padLeft(2, '0');

      if (_startDate!.year == _endDate!.year) {
        if (_startDate!.month == _endDate!.month &&
            _startDate!.day == _endDate!.day) {
          return '$startDay/$startMonth/${_startDate!.year}';
        }
        if (_startDate!.month == _endDate!.month) {
          return '$startDay - $endDay/$endMonth/${_endDate!.year}';
        }
        return '$startDay/$startMonth - $endDay/$endMonth/${_endDate!.year}';
      }

      return '$startDay/$startMonth/${_startDate!.year} - $endDay/$endMonth/${_endDate!.year}';
    }
    
    return Card(
      margin: EdgeInsets.all(isLargeScreen ? 24 : 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Filter Header
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Text(
                        _selectedFilter,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _getDateRangeText(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: isSmallScreen ? 12 : null,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 4),
                      Icon(
                        _isFilterExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable Filter Options
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isFilterExpanded ? null : 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filterOptions[index];
                    return InkWell(
                      onTap: () => _applyDateFilter(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option == _selectedFilter
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: option == _selectedFilter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairsList(bool isPaid, AppLocalizations localizations) {
    // Get screen dimensions and orientation
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final isSmallScreen = screenWidth <= 800;
    final isMobile = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return StreamBuilder<List<RepairTransaction>>(
      stream: _repairService.getRepairs(
        _userId!,
        status: isPaid ? RepairStatus.paid : RepairStatus.unpaid,
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: isMobile ? 40 : 48),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isMobile ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final repairs = snapshot.data!;
        if (repairs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                  size: isMobile ? 40 : 48,
                  color: Colors.grey,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  isPaid
                      ? localizations.noPaidRepairs
                      : localizations.noUnpaidRepairs,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Determine layout based on screen size and orientation
        final useGridView = isLargeScreen || isMediumScreen || (isSmallScreen && isLandscape && screenWidth > 600);
        
        if (useGridView) {
          // Calculate optimal grid parameters based on available space
          final crossAxisCount = isLargeScreen 
              ? 3 
              : isMediumScreen 
                  ? 2 
                  : isLandscape && screenWidth > 900 
                      ? 3 
                      : isLandscape 
                          ? 2 
                          : 1;
          
          // Adjust aspect ratio for different screen sizes and orientations
          final childAspectRatio = isLargeScreen 
              ? 1.6
              : isMediumScreen 
                  ? 1.4 
                  : isLandscape 
                      ? 1.8
                      : 1.2;

          return GridView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: isSmallScreen ? 12 : 16,
              mainAxisSpacing: isSmallScreen ? 12 : 16,
            ),
            itemCount: repairs.length,
            itemBuilder: (context, index) {
              final repair = repairs[index];
              return _buildRepairCard(repair, localizations);
            },
          );
        } else {
          // For smaller screens or portrait orientation, use a ListView
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 8 : 12,
              horizontal: isMobile ? 8 : 12,
            ),
            itemCount: repairs.length,
            itemBuilder: (context, index) {
              final repair = repairs[index];
              return _buildRepairCard(repair, localizations);
            },
          );
        }
      },
    );
  }

  Widget _buildRepairCard(
      RepairTransaction repair, AppLocalizations localizations) {
    final theme = Theme.of(context);
    final formattedDate =
        '${repair.createdAt.day.toString().padLeft(2, '0')}/${repair.createdAt.month.toString().padLeft(2, '0')}/${repair.createdAt.year}';
    
    // Detect screen size and orientation for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final isMobile = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    // Adjust margins based on screen size and orientation
    final horizontalMargin = isLargeScreen 
        ? 8.0 
        : isMobile && isLandscape 
            ? 10.0 
            : 16.0;
    
    final verticalMargin = isLargeScreen 
        ? 6.0 
        : isMobile && isLandscape 
            ? 5.0 
            : 8.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => PartsModalBottomSheet.show(
            context: context,
            repair: repair,
            onUpdateUI: () => setState(() {}),
          ),
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Column(
            children: [
              // Header with phone model and date
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, 
                  vertical: isMobile ? 10 : 12
                ),
                decoration: BoxDecoration(
                  color: repair.isPaid 
                      ? theme.colorScheme.tertiary.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Hero(
                            tag: 'phone-icon-${repair.id}',
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 6 : 8),
                              decoration: BoxDecoration(
                                color: repair.isPaid 
                                    ? theme.colorScheme.tertiary.withOpacity(0.2)
                                    : theme.colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.phone_iphone,
                                size: isMobile ? 18 : 20,
                                color: repair.isPaid 
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Text(
                              repair.phoneModel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: repair.isPaid 
                                    ? theme.colorScheme.tertiary
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : (isLandscape ? 13 : 14),
                                letterSpacing: -0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 3),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4 : (isLandscape ? 5 : 6),
                        vertical: isMobile ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: isMobile ? 9 : 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 2),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 8 : (isLandscape ? 9 : 10),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Repair details
                    if (repair.repairDetails.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 6 : 8, 
                          horizontal: isMobile ? 8 : 10
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (repair.repairDetails.length > 50 && !isLandscape)
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    size: isMobile ? 14 : 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    localizations.repairDetails,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isMobile ? 11 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            if (repair.repairDetails.length > 50 && !isLandscape)
                              SizedBox(height: isMobile ? 4 : 6),
                            Text(
                              repair.repairDetails,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: isMobile ? 13 : 14,
                              ),
                              maxLines: isLandscape ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                    ],

                    // Client information (if available)
                    if (repair.clientName != null ||
                        repair.clientPhone != null) ...[
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.15),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (repair.clientName != null &&
                                repair.clientName!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: isMobile ? 14 : 16,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  SizedBox(width: isMobile ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      repair.clientName!,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: isMobile ? 12 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (repair.clientName != null &&
                                repair.clientName!.isNotEmpty &&
                                repair.clientPhone != null &&
                                repair.clientPhone!.isNotEmpty)
                              SizedBox(height: isMobile ? 4 : 6),
                            if (repair.clientPhone != null &&
                                repair.clientPhone!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: isMobile ? 14 : 16,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  SizedBox(width: isMobile ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      repair.clientPhone!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: isMobile ? 12 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                    ],

                    // Cost information
                    Row(
                      children: [
                        // Parts count chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8, 
                            vertical: isMobile ? 4 : 5
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.build_outlined,
                                size: isMobile ? 12 : 14,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: isMobile ? 3 : 4),
                              Text(
                                '${repair.parts.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Profit badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8, 
                            vertical: isMobile ? 4 : 5
                          ),
                          decoration: BoxDecoration(
                            color: repair.totalProfit >= 0
                                ? Colors.green.withOpacity(0.1)
                                : theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: repair.totalProfit >= 0
                                  ? Colors.green.withOpacity(0.1)
                                  : theme.colorScheme.error.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                repair.totalProfit >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: isMobile ? 12 : 14,
                                color: repair.totalProfit >= 0
                                    ? Colors.green
                                    : theme.colorScheme.error,
                              ),
                              SizedBox(width: isMobile ? 3 : 4),
                              Text(
                                '${localizations.currency}${repair.totalProfit.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: repair.totalProfit >= 0
                                      ? Colors.green
                                      : theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 9 : 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Cost breakdown
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPriceInfo(
                            theme,
                            title: localizations.costPrice,
                            price: repair.totalCost,
                            isBold: false,
                            isMobile: isMobile,
                          ),
                          _buildPriceInfo(
                            theme,
                            title: localizations.sellingPrice,
                            price: repair.totalSellingPrice,
                            isBold: true,
                            isMobile: isMobile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider before action buttons
              Divider(
                height: 1,
                thickness: 0.5,
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),

              // Action buttons
              Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 6 : 8, isMobile ? 6 : 8, isMobile ? 6 : 8, isMobile ? 6 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!repair.isPaid)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _updatePaymentStatus(repair, localizations),
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: isMobile ? 16 : 18,
                        ),
                        label: Text(
                          localizations.markAsPaid,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 12, 
                            vertical: isMobile ? 4 : 6
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.colorScheme.primary,
                          elevation: 2,
                          shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
                          textStyle: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 12,
                          vertical: isMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: isMobile ? 14 : 16,
                            ),
                            SizedBox(width: isMobile ? 4 : 6),
                            Text(
                              localizations.paidRepairs,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Material(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _navigateToEditScreen(repair),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          child: Icon(
                            Icons.edit_outlined,
                            color: theme.colorScheme.primary,
                            size: isMobile ? 18 : 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Material(
                      color: theme.colorScheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showDeleteConfirmation(repair, localizations),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          child: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                            size: isMobile ? 18 : 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(
    ThemeData theme, {
    required String title,
    required double price,
    required bool isBold,
    bool isMobile = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: isMobile ? 9 : 11,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 3),
        Text(
          '${localizations.currency} ${price.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? theme.colorScheme.primary : null,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Future<void> _updatePaymentStatus(
      RepairTransaction repair, AppLocalizations localizations) async {
    try {
      await _repairService.updatePaymentStatus(repair.id, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.repairMarkedAsPaid),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorMarkingAsPaid),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
      RepairTransaction repair, AppLocalizations localizations) async {
    // Detect screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.confirmDelete,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          localizations.deleteRepairConfirmation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isSmallScreen ? 14 : 16,
              ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localizations.cancel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              localizations.delete,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repairService.deleteRepairTransaction(repair.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.repairDeleted),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.errorDeletingRepair),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEditScreen(RepairTransaction repair) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditRepairScreen(repair: repair),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildUnpaidPartsList(AppLocalizations localizations) {
    return StreamBuilder<List<RepairTransaction>>(
      stream: _repairService.getRepairs(
        _userId!,
        status: RepairStatus.all,
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Filter repairs to only include those with unpaid parts
        final allRepairs = snapshot.data!;
        final repairsWithUnpaidParts = allRepairs.where((repair) {
          return repair.parts.any((part) => !part.isCostPaid);
        }).toList();

        // Sort by date (newest first)
        repairsWithUnpaidParts
            .sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Apply search filtering if there's a query
        final filteredRepairs = _unpaidPartsSearchQuery?.isEmpty ?? true
            ? repairsWithUnpaidParts
            : repairsWithUnpaidParts.where((repair) {
                final query = _unpaidPartsSearchQuery!.toLowerCase();
                final clientName = repair.clientName?.toLowerCase() ?? '';
                final clientPhone = repair.clientPhone?.toLowerCase() ?? '';
                final phoneModel = repair.phoneModel.toLowerCase();

                return clientName.contains(query) ||
                    clientPhone.contains(query) ||
                    phoneModel.contains(query);
              }).toList();

        if (filteredRepairs.isEmpty) {
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.build_circle_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noUnpaidRepairs,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }            // Get screen dimensions and orientation for responsive layout
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = mediaQuery.size.width;
            final isLargeScreen = screenWidth > 1200;
            final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
            final isSmallScreen = screenWidth <= 800;
            final isMobile = screenWidth < 600;
            final isLandscape = mediaQuery.orientation == Orientation.landscape;

            // Determine optimal layout
            final useGridView = isLargeScreen || isMediumScreen || (isLandscape && screenWidth > 600);

            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: useGridView
                    ? GridView.builder(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen 
                              ? 3 
                              : isMediumScreen 
                                  ? 2 
                                  : isLandscape && screenWidth > 900 
                                      ? 3 
                                      : 2,
                          childAspectRatio: isLargeScreen 
                              ? 1.6 
                              : isMediumScreen 
                                  ? 1.4 
                                  : isLandscape 
                                      ? 1.8 
                                      : 1.3,
                          crossAxisSpacing: isSmallScreen ? 12 : 16,
                          mainAxisSpacing: isSmallScreen ? 12 : 16,
                        ),
                        itemCount: filteredRepairs.length,
                        itemBuilder: (context, index) {
                          final repair = filteredRepairs[index];
                          return _buildRepairWithUnpaidPartsCard(repair, localizations);
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 12,
                          horizontal: isMobile ? 8 : 12,
                        ),
                        itemCount: filteredRepairs.length,
                        itemBuilder: (context, index) {
                          final repair = filteredRepairs[index];
                          return _buildRepairWithUnpaidPartsCard(repair, localizations);
                        },
                      ),
                ),
              ],
            );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final isSmallScreen = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Calculate optimal width based on screen size and orientation
    final containerWidth = isLargeScreen
        ? screenWidth * 0.5
        : isMediumScreen
            ? screenWidth * 0.7
            : isLandscape && screenWidth > 600
                ? screenWidth * 0.8
                : double.infinity;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : isSmallScreen ? 12 : 16, 
        vertical: isLargeScreen ? 12 : isSmallScreen ? 6 : 8
      ),
      child: Center(
        child: Container(
          width: containerWidth,
          margin: (isLargeScreen || isMediumScreen || (isLandscape && screenWidth > 600)) 
              ? EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16) 
              : null,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0.5,
              )
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: localizations.searchByClientPhoneModel,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: isSmallScreen ? 13 : 14,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: isSmallScreen ? 8 : 12, right: isSmallScreen ? 4 : 8),
                child: Icon(
                  Icons.search, 
                  color: theme.colorScheme.primary,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: isSmallScreen ? 32 : 40,
                minHeight: isSmallScreen ? 32 : 40,
              ),
              suffixIcon: _unpaidPartsSearchQuery?.isNotEmpty ?? false
                  ? IconButton(
                      icon: Icon(
                        Icons.clear, 
                        color: theme.colorScheme.primary,
                        size: isSmallScreen ? 16 : 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _unpaidPartsSearchQuery = '';
                        });
                      },
                      tooltip: 'Clear',
                      constraints: BoxConstraints(
                        minWidth: isSmallScreen ? 32 : 40,
                        minHeight: isSmallScreen ? 32 : 40,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 12,
                horizontal: isSmallScreen ? 8 : 12,
              ),
              isDense: isSmallScreen,
            ),
            onChanged: (value) {
              setState(() {
                _unpaidPartsSearchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRepairWithUnpaidPartsCard(
      RepairTransaction repair, AppLocalizations localizations) {
    final theme = Theme.of(context);
    final formattedDate =
        '${repair.createdAt.day.toString().padLeft(2, '0')}/${repair.createdAt.month.toString().padLeft(2, '0')}/${repair.createdAt.year}';
    final unpaidParts = repair.parts.where((part) => !part.isCostPaid).toList();
    
    // Enhanced responsive layout detection
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;
    final isSmallScreen = screenWidth <= 800;
    final isMobile = screenWidth < 600;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    // Calculate responsive margins based on screen size
    final horizontalMargin = isLargeScreen 
        ? 12.0 
        : isMediumScreen 
            ? 10.0 
            : isMobile 
                ? (isLandscape ? 8.0 : 6.0) 
                : 8.0;
    
    final verticalMargin = isLargeScreen 
        ? 10.0 
        : isMediumScreen 
            ? 8.0 
            : isMobile 
                ? (isLandscape ? 6.0 : 5.0) 
                : 6.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 6 : 8,
            offset: const Offset(0, 2),
            spreadRadius: isMobile ? 0 : 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        child: InkWell(
          onTap: () => UnpaidPartsModalBottomSheet.show(
            context: context,
            repair: repair,
            onUpdateUI: () => setState(() {}),
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          splashColor: theme.colorScheme.error.withOpacity(0.1),
          highlightColor: theme.colorScheme.errorContainer.withOpacity(0.05),
          child: Column(
            children: [
              // Header with phone model and date
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 12
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isSmallScreen ? 12 : 16)
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 6 : 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.phone_iphone,
                              size: isMobile ? 16 : 20,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: Text(
                              repair.phoneModel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: isMobile ? 12 : 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: isMobile ? 3 : 4),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client information (if available)
                    if (repair.clientName != null ||
                        repair.clientPhone != null) ...[
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.15),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (repair.clientName != null &&
                                repair.clientName!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: isMobile ? 14 : 16,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  SizedBox(width: isMobile ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      repair.clientName!,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: isMobile ? 12 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (repair.clientName != null &&
                                repair.clientName!.isNotEmpty &&
                                repair.clientPhone != null &&
                                repair.clientPhone!.isNotEmpty)
                              SizedBox(height: isMobile ? 4 : 6),
                            if (repair.clientPhone != null &&
                                repair.clientPhone!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: isMobile ? 14 : 16,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  SizedBox(width: isMobile ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      repair.clientPhone!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: isMobile ? 12 : 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                    ],

                    // Unpaid parts summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Unpaid parts count chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 10, 
                            vertical: isMobile ? 5 : 6
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: isMobile ? 14 : 16,
                                color: theme.colorScheme.error,
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                              Text(
                                '${unpaidParts.length} ${unpaidParts.length == 1 ? localizations.part : localizations.parts}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Total cost
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 10, 
                            vertical: isMobile ? 5 : 6
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: isMobile ? 14 : 16,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                              Text(
                                '${localizations.currency} ${unpaidParts.fold(0.0, (sum, part) => sum + part.costPrice).toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // First few unpaid parts preview (limited to 2)
                    ...unpaidParts
                        .take(isLandscape && isSmallScreen ? 1 : 2)
                        .map((part) => Container(
                              margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
                              padding: EdgeInsets.all(isMobile ? 8 : 10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                                border: Border.all(
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          part.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isMobile ? 12 : 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: isMobile ? 3 : 4),
                                        Text(
                                          '${localizations.costPrice}: ${localizations.currency} ${part.costPrice.toStringAsFixed(2)}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: isMobile ? 11 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 6 : 8),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _markPartAsPaid(repair.id, part),
                                    icon: Icon(
                                      Icons.check, 
                                      size: isMobile ? 14 : 16
                                    ),
                                    label: Text(
                                      localizations.markAsPaid,
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: isMobile ? 10 : 12,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 8 : 10, 
                                        vertical: isMobile ? 4 : 6
                                      ),
                                      minimumSize: Size(0, isMobile ? 28 : 32),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),

                    // Show more button if there are more than 2 unpaid parts
                    if (unpaidParts.length > (isLandscape && isSmallScreen ? 1 : 2)) ...[
                      SizedBox(height: isMobile ? 8 : 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => UnpaidPartsModalBottomSheet.show(
                            context: context,
                            repair: repair,
                            onUpdateUI: () => setState(() {}),
                          ),
                          icon: Icon(
                            Icons.visibility,
                            size: isMobile ? 14 : 16,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            'View all ${unpaidParts.length} ${localizations.parts}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 12, 
                              vertical: isMobile ? 6 : 8
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                            ),
                            foregroundColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markPartAsPaid(String repairId, RepairPart part) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(localizations.loading),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      // Mark part as paid
      await _repairService.updatePartCostPaidStatus(repairId, part.id, true);

      // Update the UI
      setState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${part.name} marked as paid'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorWithMessage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
