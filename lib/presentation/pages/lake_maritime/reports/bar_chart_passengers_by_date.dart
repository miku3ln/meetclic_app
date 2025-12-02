import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PassengerBarChart extends StatelessWidget {
  final Map<String, Map<String, int>> dataByDate;

  const PassengerBarChart({super.key, required this.dataByDate});

  @override
  Widget build(BuildContext context) {
    final List<String> dates = dataByDate.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() + 2, // Margen superior
        groupsSpace: 20,
        barGroups: _buildBarGroups(dates),
        barTouchData: _buildTouchData(),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Fecha',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            axisNameSize: 30,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < dates.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 6,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        dates[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Cantidad de Pasajeros',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            axisNameSize: 30,
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<String> dates) {
    return dates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final values = dataByDate[date]!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values["ADULT"]!.toDouble(),
            color: Colors.blue,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: values["CHILD"]!.toDouble(),
            color: Colors.orange,
            width: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  BarTouchData _buildTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.black87,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = rodIndex == 0 ? 'Adultos' : 'Niños';
          return BarTooltipItem(
            '$label\n${rod.toY.toInt()} pasajeros',
            const TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (final entry in dataByDate.entries) {
      final values = entry.value;
      final sum = (values["ADULT"] ?? 0) + (values["CHILD"] ?? 0);
      if (sum > max) max = sum.toDouble();
    }
    return max;
  }
}
