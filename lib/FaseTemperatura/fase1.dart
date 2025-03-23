import 'dart:async';
import 'dart:convert';
import 'package:actividadfinal/FaseTemperatura/fase2.dart';
import 'package:flutter/material.dart';
import '/config/BDMysql.dart';
import '../config/conAdafruid.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final conn = BDMysql();
  final AdafruitConn adafruitConn = AdafruitConn();
  late Future<List<dynamic>> _actuDatos;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _actuDatos = obtenerDatos();
    refrescarDatos();

    obtenerNitif();

    OneSignal.Notifications.addClickListener((event) {
      print(
          "Notificación clickeada: ${event.notification.jsonRepresentation()}");
      // si la ap esta cerrada se abrira la app en la pagina de temperaturas
      Navigator.push(context, MaterialPageRoute(builder: (_) => MyHomePage()));
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          "Notificación recibida en primer plano: ${event.notification.jsonRepresentation()}");
      // mientas la app este abierta se mostrara un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${event.notification.title}")),
      );
    });
  }

  void obtenerNitif() async {
    var status = await OneSignal.Notifications.requestPermission(true);
    if (status) {
      print("Permisos de notificación concedidos");
    } else {
      print("Permisos de notificación denegados");
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
        if (i == 0) {
          final t = double.parse(temperatura[i]['value']);
          final h = double.parse(humedad[i]['value']);

          await conn.insert(t, h);

          if (t > 25) {
            _sendNotification(t);
          }
        }
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
        backgroundColor: Colors.yellow.shade700,
        title: Text("Datos temperatura y Humedad",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: actualizar, // Refrescar manualmente
            icon: Icon(Icons.refresh),
            color: Colors.white,
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
            padding: const EdgeInsets.all(12),
            itemCount:
                data.length > 15 ? 15 : data.length, // máximo 15 registros
            itemBuilder: (context, index) {
              final temp = data[index]['temperatura'];
              final hume = data[index]['humedad'];
              final fecha = data[index]['fecha'];

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.yellow.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌡 Temperatura: $temp °C",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "💧 Humedad: $hume %",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Fecha: $fecha",
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          conn.select().then((datos) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GraficaTemperatura(datos: Future.value(datos)),
              ),
            );
          });
        }, // Refrescar manualmente
        child: Icon(Icons.auto_graph),
      ),
    );
  }

  ///  Enviar notificación con OneSignal
  Future<void> _sendNotification(double tem) async {
    final subscription = OneSignal.User.pushSubscription;

    // Verifica si el usuario está suscrito
    if (subscription == null || subscription.id == null) {
      print("Usuario no suscrito. Intentando solicitar permisos...");

      ///solicitar permisos
      bool permiso = await OneSignal.Notifications.requestPermission(true);

      if (!permiso) {
        print("Permisos de notificación denegados.");
        return;
      }

      // Intenta regenerar el ID d de conceder permisos
      await Future.delayed(Duration(seconds: 2)); // pequeña espera
    }

    String? playerId = OneSignal.User.pushSubscription.id;

    if (playerId == null) {
      print(
          "No se pudo obtener el Player ID incluso después de conceder permisos.");
      return;
    }

    print("Player ID válido: $playerId");

    // Datos para la notificación
    String appId = "711694fb-4c8e-4e18-a2fa-213456646120";
    String apiKey =
        "os_v2_app_oeljj62mrzhbrix2ee2fmzdbeds6mxq2zhwunw4awadte2tgstsl4jzwiif4sjckymzzoxs6wujjdvxkdqkaxj5nmuq3ybrfxva5r4q";

    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $apiKey"
    };

    var body = jsonEncode({
      "app_id": appId,
      "include_player_ids": [playerId],
      "headings": {"en": "Temperatura en $tem °C"},
      "contents": {
        "en": "La temperatura excede los 25 °C. Valor actual: $tem °C"
      },
    });

    // Enviar la notificación
    var response = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("Notificación enviada con éxito: ${response.body}");
    } else {
      print("Error al enviar notificación: ${response.body}");
    }
  }
}
