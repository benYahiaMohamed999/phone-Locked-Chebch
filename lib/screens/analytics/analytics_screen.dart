// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/repair_service.dart';
import '../../models/repair_transaction.dart';
import '../../l10n/app_localizations.dart';

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

      print('Debug: Date range updated - Start: $_startDate, End: $_endDate');
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
              todayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary;
                }
                return theme.colorScheme.primary.withOpacity(0.1);
              }),
              todayForegroundColor: MaterialStateProperty.resolveWith((states) {
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

        print(
            'Debug: Custom date range set - Start: $_startDate, End: $_endDate');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      appBar: AppBar(
        title: Text(
          localizations.analytics,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: StreamBuilder<List<RepairTransaction>>(
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
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.errorLoadingData,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.loadingAnalyticsData,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final repairs = snapshot.data!;
          if (repairs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noRepairsForSelectedPeriod,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTimeRangeSelector(theme),
                ],
              ),
            );
          }

          // Calculate summary data
          final paidRepairs = repairs.where((r) => r.isPaid).toList();
          final totalRepairs = repairs.length;
          final totalRevenue = paidRepairs.fold(
              0.0, (sum, item) => sum + item.totalSellingPrice);
          final totalCost =
              paidRepairs.fold(0.0, (sum, item) => sum + item.totalCost);
          final totalProfit =
              paidRepairs.fold(0.0, (sum, item) => sum + item.totalProfit);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeRangeSelector(theme),
                SizedBox(height: isSmallScreen ? 16 : 24),
                _buildSummaryCards(
                    totalRepairs, totalRevenue, totalProfit, theme),
                SizedBox(height: isSmallScreen ? 16 : 24),
                _buildProfitChart(repairs, theme),
                SizedBox(height: isSmallScreen ? 16 : 24),
                _buildRepairsByStatusChart(repairs, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final dateFormat = DateFormat('MMM d, yyyy');
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
                  '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
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

  Widget _buildSummaryCards(int totalRepairs, double totalRevenue,
      double totalProfit, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;

    return isSmallScreen
        ? Column(
            children: [
              _buildSummaryCard(
                localizations.totalRepairs,
                totalRepairs.toString(),
                Icons.build,
                theme.colorScheme.primary,
                theme,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                localizations.revenue,
                currencyFormat.format(totalRevenue),
                Icons.attach_money,
                Colors.green.shade600,
                theme,
                isSmallScreen,
              ),
              const SizedBox(height: 12),
              _buildSummaryCard(
                localizations.profit,
                currencyFormat.format(totalProfit),
                Icons.trending_up,
                Colors.amber.shade700,
                theme,
                isSmallScreen,
              ),
            ],
          )
        : Row(
            children: [
              _buildSummaryCard(
                localizations.totalRepairs,
                totalRepairs.toString(),
                Icons.build,
                theme.colorScheme.primary,
                theme,
                isSmallScreen,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                localizations.revenue,
                currencyFormat.format(totalRevenue),
                Icons.attach_money,
                Colors.green.shade600,
                theme,
                isSmallScreen,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                localizations.profit,
                currencyFormat.format(totalProfit),
                Icons.trending_up,
                Colors.amber.shade700,
                theme,
                isSmallScreen,
              ),
            ],
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
    return isSmallScreen
        ? Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildProfitChart(List<RepairTransaction> repairs, ThemeData theme) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;
    final paidRepairs = repairs.where((r) => r.isPaid).toList();
    final Map<DateTime, double> dailyProfits = {};

    // Create a debug function to log info about the data
    void debugPrintData() {
      print(
          'Debug: Building profit chart with ${repairs.length} repairs, ${paidRepairs.length} paid');
    }

    debugPrintData();

    DateTime currentDate = _startDate;
    while (currentDate.isBefore(_endDate) ||
        currentDate.isAtSameMomentAs(_endDate)) {
      dailyProfits[currentDate] = 0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    for (var repair in paidRepairs) {
      final date = DateTime(
        repair.createdAt.year,
        repair.createdAt.month,
        repair.createdAt.day,
      );

      if (dailyProfits.containsKey(date)) {
        dailyProfits[date] = (dailyProfits[date] ?? 0) + repair.totalProfit;
        print('Debug: Adding profit ${repair.totalProfit} for date $date');
      }
    }

    final sortedDates = dailyProfits.keys.toList()..sort();
    final dateFormat = DateFormat('MM/dd');

    // Check if we have any data to display
    if (sortedDates.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.profitTrend,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              SizedBox(
                height: isSmallScreen ? 220 : 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noProfitDataAvailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
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

    // Create spots for the line chart
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      final profit = dailyProfits[sortedDates[i]] ?? 0;
      spots.add(FlSpot(i.toDouble(), profit));
    }

    print('Debug: Created ${spots.length} spots for chart');
    // Check if we have any non-zero values
    bool hasData = spots.any((spot) => spot.y > 0);
    if (!hasData) {
      print('Debug: No profit values greater than zero found');
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.profitTrend,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizations.daily,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            SizedBox(
              height: isSmallScreen ? 220 : 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: hasData
                      ? spots
                              .map((spot) => spot.y)
                              .reduce((a, b) => a > b ? a : b) *
                          1.2
                      : 100,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor:
                          theme.colorScheme.surface.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          if (idx < 0 || idx >= sortedDates.length) {
                            return LineTooltipItem(
                              localizations.noData,
                              TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          final date = sortedDates[idx];
                          return LineTooltipItem(
                            '${dateFormat.format(date)}\n\$${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: spots.length > 10
                            ? (spots.length / (isSmallScreen ? 3 : 5))
                                .round()
                                .toDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= sortedDates.length) {
                            return const Text('');
                          }
                          final date = sortedDates[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dateFormat.format(date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                fontSize: isSmallScreen ? 8 : 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isSmallScreen ? 36 : 40,
                        interval: isSmallScreen ? 100 : 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: isSmallScreen ? 8 : 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.7),
                          theme.colorScheme.primary,
                        ],
                      ),
                      barWidth: isSmallScreen ? 2 : 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.primary.withOpacity(0.01),
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

  Widget _buildRepairsByStatusChart(
      List<RepairTransaction> repairs, ThemeData theme) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;
    final paidRepairs = repairs.where((r) => r.isPaid).length;
    final unpaidRepairs = repairs.length - paidRepairs;
    final paidPercentage =
        repairs.isEmpty ? 0 : (paidRepairs / repairs.length * 100);
    final unpaidPercentage = 100 - paidPercentage;

    print(
        'Debug: Repairs by status - Total: ${repairs.length}, Paid: $paidRepairs, Unpaid: $unpaidRepairs');

    // If there is no data, show a placeholder
    if (repairs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.repairStatus,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              SizedBox(
                height: isSmallScreen ? 180 : 220,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.noRepairDataAvailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.repairStatus,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            isSmallScreen
                ? Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: paidRepairs.toDouble() == 0
                                    ? 0.01
                                    : paidRepairs.toDouble(),
                                title: '',
                                color: Colors.green.shade400,
                                radius: 60,
                                titleStyle: TextStyle(fontSize: 0),
                              ),
                              PieChartSectionData(
                                value: unpaidRepairs.toDouble() == 0
                                    ? 0.01
                                    : unpaidRepairs.toDouble(),
                                title: '',
                                color: Colors.red.shade400,
                                radius: 55,
                                titleStyle: TextStyle(fontSize: 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusLegendItem(
                            localizations.paidRepairs,
                            paidRepairs.toString(),
                            '${paidPercentage.toStringAsFixed(1)}%',
                            Colors.green.shade400,
                            theme,
                          ),
                          _buildStatusLegendItem(
                            localizations.unpaidRepairs,
                            unpaidRepairs.toString(),
                            '${unpaidPercentage.toStringAsFixed(1)}%',
                            Colors.red.shade400,
                            theme,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: paidRepairs.toDouble() == 0
                                      ? 0.01
                                      : paidRepairs.toDouble(),
                                  title: '',
                                  color: Colors.green.shade400,
                                  radius: 60,
                                  titleStyle: TextStyle(fontSize: 0),
                                ),
                                PieChartSectionData(
                                  value: unpaidRepairs.toDouble() == 0
                                      ? 0.01
                                      : unpaidRepairs.toDouble(),
                                  title: '',
                                  color: Colors.red.shade400,
                                  radius: 55,
                                  titleStyle: TextStyle(fontSize: 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusLegendItem(
                                localizations.paidRepairs,
                                paidRepairs.toString(),
                                '${paidPercentage.toStringAsFixed(1)}%',
                                Colors.green.shade400,
                                theme,
                              ),
                              const SizedBox(height: 16),
                              _buildStatusLegendItem(
                                localizations.unpaidRepairs,
                                unpaidRepairs.toString(),
                                '${unpaidPercentage.toStringAsFixed(1)}%',
                                Colors.red.shade400,
                                theme,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
