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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _navegacionPantalla.elementAt(_seleccion),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.green,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.text_decrease_sharp,
              color: Colors.white,
            ),
            label: 'AI2',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.swap_vert,
              color: Colors.orange,
            ),
            label: 'AI3',
          ),
        ],
        // Color de la etiqueta y el icono seleccionado
        selectedItemColor: Colors.blue,
        // Color de la etiqueta y el icono no seleccionados
        unselectedItemColor: Colors.grey,

        currentIndex: _seleccion,
        onTap: _mostrar,
      ),
    );
  }

  List<Widget> _navegacionPantalla = <Widget>[
    Home(),
    LEDControl(),
    MyHomePage(),
  ];

  _mostrar(int index) {
    setState(() {
      _seleccion = index;
    });
  }
}
