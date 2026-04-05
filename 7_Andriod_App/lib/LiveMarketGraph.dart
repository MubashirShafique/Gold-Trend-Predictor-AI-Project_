import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/prediction_response.dart';

// ================== LIVE MARKET GRAPH WIDGET ==================
class LiveMarketGraph extends StatelessWidget {
  final List<FlSpot> chartData;
  final List<String> labels; // Dates ya x-axis labels
  final Color lineColor;
  final String selectedPeriod;

  const LiveMarketGraph({
    Key? key,
    required this.chartData,
    required this.labels,
    this.lineColor = const Color(0xFFFFD700),
    this.selectedPeriod = "7 Days",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(5, 20, 15, 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (labels.isEmpty) return const Text('');
                  int index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    final dateParts = labels[index].split("-");
                    return Text("${dateParts[1]}-${dateParts[2]}",
                        style: const TextStyle(color: Colors.white38, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text("\$${value.toInt()}",
                    style: const TextStyle(color: Colors.white38, fontSize: 9)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(min) - 50 : 0,
          maxY: chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(max) + 50 : 100,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              gradient: LinearGradient(
                  colors: [lineColor, Colors.orangeAccent]),
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.2),
                    lineColor.withOpacity(0.0)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== EXTENSION FOR LIST ==================
extension ListExtension<T> on List<T> {
  List<T> takeLast(int n) => sublist(length - n < 0 ? 0 : length - n);
}