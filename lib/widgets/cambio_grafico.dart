import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class CambioGrafico extends StatelessWidget {
  final Map<DateTime, double> historico;

  const CambioGrafico({super.key, required this.historico});

  @override
  Widget build(BuildContext context) {
    final dias = historico.keys.toList()..sort();
    final spots = dias.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), historico[e.value]!);
    }).toList();

    // 1) Calcular minY e maxY
    final valores = historico.values.toList();
    final minY = valores.reduce(min);
    final maxY = valores.reduce(max);

    // 2) Definir um intervalo dinâmico (4 subdivisões)
    final range = maxY - minY;
    final step = range / 4;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          // 3) Aplicar limites Y
          minY: minY,
          maxY: maxY,

          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),

          // 4) Títulos: só o eixo esquerdo, nos pontos minY + n*step
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: step,
                getTitlesWidget: (value, _) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          lineTouchData: LineTouchData(
            enabled: true,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((i) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: Colors.purple,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  FlDotData(show: true),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 6,
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(2),
                  const TextStyle(color: Colors.black),
                );
              }).toList(),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple.withOpacity(0.3),
                    Colors.purple.withOpacity(0.05),
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
