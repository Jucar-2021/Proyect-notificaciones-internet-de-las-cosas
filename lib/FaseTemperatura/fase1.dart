import 'dart:async';
import 'package:flutter/material.dart';
import '/config/BDMysql.dart';
import '../config/conAdafruid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final conn = BDMysql.getConnection();
  final AdafruitConn adafruitConn = AdafruitConn();
  late Future<List<dynamic>> _actuDatos;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _actuDatos = obtenerDatos();
    refrescarDatos();

    if (conn != null) {
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Conexión exitosa a MySQL");
    }
  }

  /// Obtiene los datos de temperatura y humedad en un solo Future
  Future<List<Map<String, dynamic>>> obtenerDatos() async {
    try {
      final List<dynamic> temperatura = await adafruitConn.fetchTemper();
      final List<dynamic> humedad = await adafruitConn.fetchHumedad();

      // Unir temperatura y humedad en una lista combinada
      List<Map<String, dynamic>> datosCombinados = [];

      for (int i = 0; i < temperatura.length; i++) {
        datosCombinados.add({
          'temperatura': temperatura[i]['value'],
          'humedad': (i < humedad.length) ? humedad[i]['value'] : 'N/A',
          'fecha': temperatura[i]['created_at'],
        });
      }

      return datosCombinados;
    } catch (e) {
      throw Exception("Error obteniendo datos: $e");
    }
  }

  /// Actualiza los datos de manera manual
  void actualizar() {
    setState(() {
      _actuDatos = obtenerDatos();
    });
  }

  /// Actualiza los datos automáticamente cada 30 segundos
  void refrescarDatos() {
    _timer = Timer.periodic(
      Duration(seconds: 30),
      (timer) {
        actualizar();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detener el Timer cuando la pantalla se cierre
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Datos temperatura y Humedad"),
        actions: [
          IconButton(
            onPressed: actualizar, // Refrescar manualmente
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _actuDatos as dynamic,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay datos disponibles"));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Temperatura: ${data[index]['temperatura']}°C"),
                subtitle: Text(
                    "Humedad: ${data[index]['humedad']}%\n Fecha: ${data[index]['fecha']}"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: actualizar, // Refrescar manualmente
        child: Icon(Icons.auto_graph),
      ),
    );
  }
}
