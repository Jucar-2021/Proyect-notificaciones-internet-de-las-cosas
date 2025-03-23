import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraficaTemperatura extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> datos;

  const GraficaTemperatura({required this.datos, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: datos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay datos disponibles."));
        }

        final datos = snapshot.data!;

        final datosValidos = datos.where((d) {
          final t = d['tem'];
          final h = d['humeda'];
          return t != null &&
              h != null &&
              double.tryParse(t.toString()) != null &&
              double.tryParse(h.toString()) != null;
        }).toList();

        if (datosValidos.isEmpty) {
          return const Center(
              child: Text("No hay datos válidos para graficar."));
        }

        final puntosTemp = List.generate(datosValidos.length, (index) {
          final t =
              double.tryParse(datosValidos[index]['tem'].toString()) ?? 0.0;
          return FlSpot(index.toDouble(), t);
        });

        final puntosHume = List.generate(datosValidos.length, (index) {
          final h =
              double.tryParse(datosValidos[index]['humeda'].toString()) ?? 0.0;
          return FlSpot(index.toDouble(), h);
        });

        final valoresTemp = puntosTemp.map((p) => p.y).toList();
        final minYTemp = valoresTemp.reduce((a, b) => a < b ? a : b) - 2;
        final maxYTemp = valoresTemp.reduce((a, b) => a > b ? a : b) + 2;

        final valoresHume = puntosHume.map((p) => p.y).toList();
        final minYHume = valoresHume.reduce((a, b) => a < b ? a : b) - 2;
        final maxYHume = valoresHume.reduce((a, b) => a > b ? a : b) + 2;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Temperatura (°C)",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.white,
                    minY: minYTemp,
                    maxY: maxYTemp,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            final fecha = datosValidos[index]['fecha'] ?? '';
                            final temp = spot.y.toStringAsFixed(1);
                            return LineTooltipItem(
                              "Temp: $temp°C\nFecha: $fecha",
                              const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        spots: puntosTemp,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                "Humedad (%)",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.white,
                    minY: minYHume,
                    maxY: maxYHume,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            final fecha = datosValidos[index]['fecha'] ?? '';
                            final hume = spot.y.toStringAsFixed(1);
                            return LineTooltipItem(
                              "Humedad: $hume%\nFecha: $fecha",
                              const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        spots: puntosHume,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
