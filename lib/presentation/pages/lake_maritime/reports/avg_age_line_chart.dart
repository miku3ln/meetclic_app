import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AvgAgeLineChart extends StatelessWidget {
  final Map<String, double> dataByDate;

  const AvgAgeLineChart({super.key, required this.dataByDate});

  @override
  Widget build(BuildContext context) {
    final List<String> dates = dataByDate.keys.toList();
    final List<double> values = dataByDate.values.toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: values.reduce((a, b) => a > b ? a : b) + 5,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              dates.length,
                  (index) => FlSpot(index.toDouble(), values[index]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Edad Promedio'),
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Fecha'),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                return i < dates.length
                    ? Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    dates[i], // Usa el formato ya formateado 'dd-MM-yyyy'
                    style: const TextStyle(fontSize: 10),
                  ),
                )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
