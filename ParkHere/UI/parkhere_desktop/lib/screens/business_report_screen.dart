import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkhere_desktop/providers/business_report_provider.dart';
import 'package:parkhere_desktop/layouts/master_screen.dart';
import 'package:parkhere_desktop/model/business_report.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessReportScreen extends StatefulWidget {
  const BusinessReportScreen({super.key});

  @override
  State<BusinessReportScreen> createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends State<BusinessReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Color> _chartColors = [
    const Color(0xFF1E3A8A), // Deep Blue
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF97316), // Orange
  ];

  int _touchedSpotIndex = -1;
  int _touchedGenderIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessReportProvider>().getBusinessReport();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Business Analytics",
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<BusinessReportProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                ),
              );
            }

            if (provider.error != null) {
              return _buildErrorView(provider);
            }

            final report = provider.businessReport;
            if (report == null) {
              return const Center(child: Text('No analytical data available'));
            }

            return _buildDashboard(report);
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BusinessReportResponse report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        bool isLargeScreen = availableWidth > 1100;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedItem(0, _buildHeaderSection(report)),
              const SizedBox(height: 32),
              _buildAnimatedItem(1, _buildMainStats(report, availableWidth)),
              const SizedBox(height: 32),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                children: [
                  SizedBox(
                    width: isLargeScreen ? (availableWidth - 96) * 0.65 : availableWidth - 64,
                    child: report.monthlyRevenueTrends.isEmpty 
                      ? _buildNoDataPlaceholder("No revenue data available")
                      : _buildAnimatedItem(2, _buildRevenueChart(report)),
                  ),
                  SizedBox(
                    width: isLargeScreen ? (availableWidth - 96) * 0.35 : availableWidth - 64,
                    child: report.spotTypeDistribution.isEmpty
                      ? _buildNoDataPlaceholder("No spot type data")
                      : _buildAnimatedItem(3, _buildSpotTypePie(report)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                children: [
                  SizedBox(
                    width: isLargeScreen ? (availableWidth - 128) / 3 : availableWidth - 64,
                    child: report.sectorDistribution.isEmpty
                      ? _buildNoDataPlaceholder("No sector data")
                      : _buildAnimatedItem(4, _buildSectorDistribution(report)),
                  ),
                  SizedBox(
                    width: isLargeScreen ? (availableWidth - 128) / 3 : availableWidth - 64,
                    child: report.genderDistribution.isEmpty
                      ? _buildNoDataPlaceholder("No gender data")
                      : _buildAnimatedItem(5, _buildGenderDistribution(report)),
                  ),
                  SizedBox(
                    width: isLargeScreen ? (availableWidth - 128) / 3 : availableWidth - 64,
                    child: _buildAnimatedItem(6, _buildPopularItemsList(report)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (0.1 * index).clamp(0.0, 1.0),
          (0.1 * index + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildHeaderSection(BusinessReportResponse report) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Performance Overview",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              "Real-time analytics and parking insights for ${DateTime.now().year}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<BusinessReportProvider>().getBusinessReport();
            _animationController.reset();
            _animationController.forward();
          },
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text("Refresh Data"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats(BusinessReportResponse report, double availableWidth) {
    return Container(
      width: availableWidth,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 48,
        runSpacing: 24,
        alignment: WrapAlignment.spaceAround,
        children: [
          _buildStatItem("Total Revenue", "${report.totalRevenue.toStringAsFixed(2)} KM", Icons.account_balance_wallet_rounded, const Color(0xFF1E3A8A)),
          _buildStatItem("Total Reservations", report.totalReservations.toString(), Icons.local_parking_rounded, const Color(0xFF10B981)),
          _buildStatItem("Active Users", report.totalUsers.toString(), Icons.people_alt_rounded, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title, 
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)
            ),
            const SizedBox(height: 6),
            Text(
              value, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BusinessReportResponse report) {
    return _buildChartContainer(
      title: "Monthly Revenue Flow",
      subtitle: "Earnings trend over the year",
      child: AspectRatio(
        aspectRatio: 1.8,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max || value == meta.min) return const Text("");
                    return Text("${value.toInt()} KM", 
                      style: TextStyle(color: Colors.grey[400], fontSize: 10));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1, // Ensure all months potentially show but we can filter
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report.monthlyRevenueTrends.length) {
                      // Only show every 2nd label if screen is small? 
                      // For now, let's just make sure they have space.
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(report.monthlyRevenueTrends[value.toInt()].month,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      );
                    }
                    return const Text("");
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: report.monthlyRevenueTrends.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.revenue.toDouble());
                }).toList(),
                isCurved: true,
                color: const Color(0xFF1E3A8A),
                barWidth: 4,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A).withOpacity(0.3),
                      const Color(0xFF1E3A8A).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      "${report.monthlyRevenueTrends[spot.x.toInt()].month}: ${spot.y.toStringAsFixed(2)} KM",
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpotTypePie(BusinessReportResponse report) {
    return _buildChartContainer(
      title: "Spot Type Demand",
      subtitle: "Usage by parking type",
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: report.spotTypeDistribution.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedSpotIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 70.0 : 60.0;
                  final percentage = report.totalReservations > 0 
                      ? (e.value.count / report.totalReservations) * 100 
                      : 0.0;
                  
                  return PieChartSectionData(
                    color: _chartColors[e.key % _chartColors.length],
                    value: e.value.count.toDouble(),
                    title: isTouched 
                        ? "${e.value.count} res\n${e.value.revenue?.toStringAsFixed(0)} KM"
                        : "${percentage.toStringAsFixed(0)}%",
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      shadows: isTouched ? [const Shadow(color: Colors.black, blurRadius: 2)] : [],
                    ),
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedSpotIndex = -1;
                        return;
                      }
                      _touchedSpotIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...report.spotTypeDistribution.asMap().entries.map((e) {
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _chartColors[e.key % _chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text("${item.count} res", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 8),
                  Text("${item.revenue?.toStringAsFixed(0)} KM", 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectorDistribution(BusinessReportResponse report) {
    return _buildChartContainer(
      title: "Sector Occupancy",
      subtitle: "Reservations per sector",
      child: AspectRatio(
        aspectRatio: 1.3,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: report.sectorDistribution.isEmpty ? 10 : report.sectorDistribution.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report.sectorDistribution.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(report.sectorDistribution[value.toInt()].name,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
                      );
                    }
                    return const Text("");
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: report.sectorDistribution.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.count.toDouble(),
                    gradient: LinearGradient(
                      colors: [
                        _chartColors[e.key % _chartColors.length],
                        _chartColors[e.key % _chartColors.length].withOpacity(0.7),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 28,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = report.sectorDistribution[group.x.toInt()];
                  return BarTooltipItem(
                    "${item.name}\n${item.count} Res\n${item.revenue?.toStringAsFixed(2)} KM",
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularItemsList(BusinessReportResponse report) {
    return _buildChartContainer(
      title: "Popularity Insights",
      subtitle: "Top performing parking units",
      child: Column(
        children: [
          _buildPopularRow("Most Active Spot", report.mostPopularSpot?.name ?? "N/A", Icons.place_rounded),
          _buildPopularRow("Top Category", report.mostPopularType?.name ?? "N/A", Icons.category_rounded),
          _buildPopularRow("Busiest Wing", report.mostPopularWing?.name ?? "N/A", Icons.door_front_door_rounded),
          _buildPopularRow("Primary Sector", report.mostPopularSector?.name ?? "N/A", Icons.dashboard_customize_rounded),
        ],
      ),
    );
  }

  Widget _buildPopularRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A))),
          )
        ],
      ),
    );
  }

  Widget _buildGenderDistribution(BusinessReportResponse report) {
    return _buildChartContainer(
      title: "Gender Analytics",
      subtitle: "Reservations and spending by gender",
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: report.genderDistribution.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedGenderIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  final percentage = report.totalReservations > 0 
                      ? (e.value.count / report.totalReservations) * 100 
                      : 0.0;

                  return PieChartSectionData(
                    color: e.value.name == "Male" ? const Color(0xFF1E3A8A) : const Color(0xFFEC4899),
                    value: e.value.count.toDouble(),
                    title: isTouched 
                        ? "${e.value.count} res\n${e.value.revenue?.toStringAsFixed(0)} KM"
                        : "${percentage.toStringAsFixed(0)}%",
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      shadows: isTouched ? [const Shadow(color: Colors.black, blurRadius: 2)] : [],
                    ),
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedGenderIndex = -1;
                        return;
                      }
                      _touchedGenderIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...report.genderDistribution.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.name == "Male" ? const Color(0xFF1E3A8A) : const Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text("${item.count} res", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(width: 12),
                Text("${item.revenue?.toStringAsFixed(0)} KM", 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildNoDataPlaceholder(String message) {
    return _buildChartContainer(
      title: "No Data",
      subtitle: message,
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer({required String title, required String subtitle, required Widget child}) {
    return _HoverCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle, 
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BusinessReportProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Failed to load analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(provider.error ?? "Unknown error", style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.getBusinessReport(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            child: const Text("Try Again"),
          )
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFE5E7EB),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.04),
              blurRadius: _isHovered ? 30 : 15,
              offset: Offset(0, _isHovered ? 15 : 6),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
