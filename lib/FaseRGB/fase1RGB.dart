import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/conAdafruid.dart';
import 'dart:math';

class LEDControl extends StatefulWidget {
  @override
  _LEDControlState createState() => _LEDControlState();
}

class _LEDControlState extends State<LEDControl> {
  final AdafruitConn adafruitConn = AdafruitConn();
  double colorLed = 0; // Valor entre 0 y 360

  Color get currentColor => HSVColor.fromAHSV(1, colorLed, 1, 1).toColor();

  void _onHueChanged(double value) {
    setState(() {
      colorLed = value;
    });
    adafruitConn.enviarColor(currentColor); // Envía color en tiempo real
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control LED RGB"),
        backgroundColor: currentColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selecciona un color:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Color preview
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black54, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                // Vertical hue slider
                Column(
                  children: [
                    RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 35,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 30,
                          ),
                          activeTrackColor: Colors.green,
                          inactiveTrackColor: Colors.yellow,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          min: 0,
                          max: 360,
                          value: colorLed,
                          divisions: 360,
                          label: "${colorLed.toInt()}°",
                          onChanged: (value) {
                            setState(() {
                              colorLed = value;
                            });
                          },
                          onChangeEnd: (value) {
                            adafruitConn.enviarColor(
                                currentColor); // Solo se envía al soltar
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("barra de seleccion de color"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
