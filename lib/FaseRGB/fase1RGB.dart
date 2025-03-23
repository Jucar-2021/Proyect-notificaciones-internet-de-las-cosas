import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/conAdafruid.dart';

class LEDControl extends StatefulWidget {
  @override
  _LEDControlState createState() => _LEDControlState();
}

class _LEDControlState extends State<LEDControl> {
  final AdafruitConn adafruitConn = AdafruitConn();
  double redValue = 255;
  double greenValue = 0;
  double blueValue = 0;

  Color selectedColor = Color.fromRGBO(255, 0, 0, 1);

  List<Color> presetColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.white,
    Colors.cyan,
  ];

  void enviarColor() {
    adafruitConn.enviarColor(selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control LED RGB"),
        backgroundColor: selectedColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildColorPreview(),
              SizedBox(height: 24),
              _buildColorSliders(),
              SizedBox(height: 24),
              Text(
                'Preajustes de Color predefinidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildColorPresets(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: selectedColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: selectedColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            // ignore: deprecated_member_use
            '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              color: selectedColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajustes RGB',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildSlider('R', redValue, Colors.red, (value) {
          setState(() {
            redValue = value;
            selectedColor = Color.fromRGBO(
                redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
          });
        }),
        _buildSlider('G', greenValue, Colors.green, (value) {
          setState(() {
            greenValue = value;
            selectedColor = Color.fromRGBO(
                redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
          });
        }),
        _buildSlider('B', blueValue, Colors.blue, (value) {
          setState(() {
            blueValue = value;
            selectedColor = Color.fromRGBO(
                redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
          });
        }),
      ],
    );
  }

  Widget _buildSlider(
      String label, double value, Color color, Function(double) onChanged) {
    return Row(
      children: [
        Container(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            activeColor: color,
            // ignore: deprecated_member_use
            inactiveColor: color.withOpacity(0.3),
            onChanged: (val) => onChanged(val),
            onChangeEnd: (val) => enviarColor(),
          ),
        ),
        SizedBox(
          width: 45,
          child: Text(
            value.toInt().toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPresets() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presetColors.length,
        itemBuilder: (context, index) {
          final Color color = presetColors[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = color;
                // ignore: deprecated_member_use
                redValue = color.red.toDouble();
                // ignore: deprecated_member_use
                greenValue = color.green.toDouble();
                // ignore: deprecated_member_use
                blueValue = color.blue.toDouble();
              });
              enviarColor();
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == color
                      ? Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.4),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
