import 'package:actividadfinal/FaseRGB/fase1RGB.dart';
import 'package:actividadfinal/home.dart';
import 'package:flutter/material.dart';
import 'FaseTemperatura/fase1.dart';

class MenuNav extends StatefulWidget {
  const MenuNav({super.key, required this.title});
  final String title;

  @override
  State<MenuNav> createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> {
  int _seleccion = 0;

  final List<Widget> _navegacionPantalla = <Widget>[
    Home(),
    LEDControl(),
    MyHomePage(),
  ];

  _mostrar(int index) {
    setState(() {
      _seleccion = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navegacionPantalla[_seleccion],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            currentIndex: _seleccion,
            onTap: _mostrar,
            selectedItemColor: Colors.teal.shade600,
            unselectedItemColor: Colors.grey.shade500,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb),
                label: 'RGB',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.thermostat_auto),
                label: '°C y %',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
