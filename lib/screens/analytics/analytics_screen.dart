// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/repair_service.dart';
import '../../models/repair_transaction.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/animated_responsive_card.dart';

class AnalyticsData {
  final int totalRepairs;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;

  final double totalServiceCost;

  AnalyticsData({
    required this.totalRepairs,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalServiceCost,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final RepairService _repairService = RepairService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String? _userId;
  int _selectedTimeRange = 7; // Default 7 days

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        // Clear current time to avoid time-of-day issues with filtering
        final now = DateTime.now();
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        _startDate = DateTime(now.year, now.month, now.day - 6);
      });
    }
  }

  void _updateDateRange(int days) {
    setState(() {
      _selectedTimeRange = days;

      // Clear current time to avoid time-of-day issues with filtering
      final now = DateTime.now();
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Set the start date based on the selected range
      if (days == 7) {
        _startDate = DateTime(now.year, now.month, now.day - 6);
      } else if (days == 30) {
        _startDate = DateTime(now.year, now.month - 1, now.day);
      } else if (days == 90) {
        _startDate = DateTime(now.year, now.month - 3, now.day);
      } else if (days == 365) {
        _startDate = DateTime(now.year - 1, now.month, now.day);
      }

      if (kDebugMode) {
        print('Debug: Date range updated - Start: $_startDate, End: $_endDate');
      }
    });
  }

  Future<void> _selectDateRange() async {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isSmallScreen = mediaQuery.size.width < 600;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
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
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.onPrimary;
                }
                return null;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary;
                }
                // ignore: deprecated_member_use
                return theme.colorScheme.primary.withOpacity(0.1);
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.onPrimary;
                }
                return theme.colorScheme.primary;
              }),
              rangePickerBackgroundColor:
                  // ignore: deprecated_member_use
                  theme.colorScheme.primary.withOpacity(0.1),
              rangePickerShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              rangeSelectionBackgroundColor:
              // ignore: deprecated_member_use
                  theme.colorScheme.primary.withOpacity(0.2),
                  // ignore: deprecated_member_use
              rangeSelectionOverlayColor: MaterialStateProperty.all(
                // ignore: deprecated_member_use
                theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
          ),
          child: MediaQuery(
            // Make date picker adapt to screen size
            data: MediaQuery.of(context).copyWith(
              // ignore: deprecated_member_use
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
        _selectedTimeRange = 0; // Custom range
        // Set time to start of day for start date
        _startDate = DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
          0,
          0,
          0,
        );
        // Set time to end of day for end date
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );

        log(
            'Debug: Custom date range set - Start: $_startDate, End: $_endDate');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
      largeDesktop: _buildLargeDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: ResponsiveText(
          text: 'Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const ResponsiveSpacing(),
            _buildStatsCards(),
            const ResponsiveSpacing(),
            _buildRevenueChart(),
            const ResponsiveSpacing(),
            _buildRepairsChart(),
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: ResponsiveText(
          text: 'Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeSelector(),
              const ResponsiveSpacing(),
              _buildStatsCards(),
              const ResponsiveSpacing(),
              _buildRevenueChart(),
              const ResponsiveSpacing(),
              _buildRepairsChart(),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ResponsivePadding(
        desktopPadding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                text: 'Analytics',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              ResponsiveSpacing(),
              _buildDateRangeSelector(),
              ResponsiveSpacing(),
              _buildStatsCards(),
              ResponsiveSpacing(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRevenueChart(),
                  ),
                  ResponsiveSpacing(isVertical: false),
                  Expanded(
                    flex: 1,
                    child: _buildRepairsChart(),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeDesktopLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ResponsivePadding(
        desktopPadding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                text: 'Analytics',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              ResponsiveSpacing(desktopSpacing: 32),
              _buildDateRangeSelector(),
              ResponsiveSpacing(desktopSpacing: 40),
              _buildStatsCards(),
              ResponsiveSpacing(desktopSpacing: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRevenueChart(),
                  ),
                  ResponsiveSpacing(desktopSpacing: 32, isVertical: false),
                  Expanded(
                    flex: 1,
                    child: _buildRepairsChart(),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${localizations.dateRange}:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: isSmallScreen
                ? Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _timeRangeButton(localizations.sevenD, 7, theme),
                      _timeRangeButton(localizations.thirtyD, 30, theme),
                      _timeRangeButton(localizations.ninetyD, 90, theme),
                      _timeRangeButton(localizations.ytd, 365, theme),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month,
                          color: _selectedTimeRange == 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: _selectDateRange,
                        tooltip: localizations.customRange,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _timeRangeButton(localizations.sevenD, 7, theme),
                      _timeRangeButton(localizations.thirtyD, 30, theme),
                      _timeRangeButton(localizations.ninetyD, 90, theme),
                      _timeRangeButton(localizations.ytd, 365, theme),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month,
                          color: _selectedTimeRange == 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: _selectDateRange,
                        tooltip: localizations.customRange,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _timeRangeButton(String label, int days, ThemeData theme) {
    final isSelected = _selectedTimeRange == days;

    return InkWell(
      onTap: () => _updateDateRange(days),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;

    return StreamBuilder<List<RepairTransaction>>(
      stream: _repairService.getRepairs(
        _userId!,
        status: RepairStatus.all,
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ResponsiveContainer(
            child: AnimatedResponsiveCard(
              child: Center(
                child: ResponsiveText(
                  text: 'Error loading data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return ResponsiveContainer(
            child: AnimatedResponsiveCard(
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          );
        }

        final repairs = snapshot.data!;
        final paidRepairs = repairs.where((r) => r.isPaid).toList();
        final totalRepairs = repairs.length;
        final totalRevenue = paidRepairs.fold(0.0, (sum, item) => sum + item.totalSellingPrice);
        final totalProfit = paidRepairs.fold(0.0, (sum, item) => sum + item.totalProfit);

        return ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          children: [
            _buildSummaryCard(
              localizations.totalRepairs,
              totalRepairs.toString(),
              Icons.build,
              theme.colorScheme.primary,
              theme,
              isSmallScreen,
            ),
            _buildSummaryCard(
              localizations.revenue,
              NumberFormat.currency(symbol: '\$').format(totalRevenue),
              Icons.attach_money,
              Colors.green.shade600,
              theme,
              isSmallScreen,
            ),
            _buildSummaryCard(
              localizations.profit,
              NumberFormat.currency(symbol: '\$').format(totalProfit),
              Icons.trending_up,
              Colors.amber.shade700,
              theme,
              isSmallScreen,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    return ResponsiveContainer(
      child: AnimatedResponsiveCard(
        child: isSmallScreen
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          text: title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ResponsiveText(
                          text: value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      ResponsiveText(
                        text: title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  ResponsiveSpacing(),
                  ResponsiveText(
                    text: value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ResponsiveContainer(
      child: AnimatedResponsiveCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveText(
                  text: 'Revenue Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ResponsiveSpacing(),
            SizedBox(
              height: isSmallScreen ? 220 : 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6.0,
                  minY: 0,
                  maxY: 100,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.surface,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.x.toStringAsFixed(1)}\n\$${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              fontSize: isSmallScreen ? 8 : 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isSmallScreen ? 36 : 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              fontSize: isSmallScreen ? 8 : 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 50),
                        FlSpot(1, 70),
                        FlSpot(2, 60),
                        FlSpot(3, 80),
                        FlSpot(4, 75),
                        FlSpot(5, 90),
                        FlSpot(6, 85),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            theme.colorScheme.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepairsChart() {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ResponsiveContainer(
      child: AnimatedResponsiveCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              text: 'Repair Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ResponsiveSpacing(),
            SizedBox(
              height: isSmallScreen ? 180 : 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: '',
                      color: Colors.green.shade400,
                      radius: 60,
                      titleStyle: TextStyle(fontSize: 0),
                    ),
                    PieChartSectionData(
                      value: 60,
                      title: '',
                      color: Colors.red.shade400,
                      radius: 55,
                      titleStyle: TextStyle(fontSize: 0),
                    ),
                  ],
                ),
              ),
            ),
            ResponsiveSpacing(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusLegendItem(
                  'Paid Repairs',
                  '40',
                  '40%',
                  Colors.green.shade400,
                  theme,
                ),
                _buildStatusLegendItem(
                  'Unpaid Repairs',
                  '60',
                  '60%',
                  Colors.red.shade400,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegendItem(
    String label,
    String count,
    String percentage,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            count,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            percentage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
