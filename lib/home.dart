import 'package:flutter/material.dart';
import 'dart:math' as math;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacion;

  @override
  void initState() {
    super.initState();

    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _animacion = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> integrantes = [
    '1. Juan Carlos García Lucero',
    '2. Javier Gerardo Lamas Hernández',
    '3. Francisco Javier González Ginez',
    '4. Uriel Rodríguez Olguín',
    '5. Rodolfo Piñera Blanco',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text(
          'Presentacion Equipo-4',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Imagen rotando
            Center(
              child: AnimatedBuilder(
                animation: _animacion,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspectiva
                      ..rotateY(_animacion.value), // rotacion en eje y
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                  );
                },
              ),
            ),
            const Text(
              'AG5. Construcción de un Dispositivo Inteligente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(thickness: 1),
            const Text(
              'Integrantes del equipo:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...integrantes.map(
              (nombre) => Text(
                nombre,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
