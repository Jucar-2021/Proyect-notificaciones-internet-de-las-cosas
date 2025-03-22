import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/conAdafruid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LEDControl extends StatefulWidget {
  @override
  _LEDControlState createState() => _LEDControlState();
}

class _LEDControlState extends State<LEDControl> {
 
  final AdafruitConn adafruitConn = AdafruitConn();
  Color _currentColor = Colors.black;


  /// Muestra el selector de color
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Selecciona un color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() => _currentColor = color);
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () {
              adafruitConn.enviarColor(_currentColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Control LED RGB")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Color seleccionado:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showColorPicker,
              child: Text("Elegir Color"),
            ),
          ],
        ),
      ),
    );
  }
}
