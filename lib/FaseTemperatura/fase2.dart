import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config/BDMysql.dart';
import '../config/conAdafruid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final conn = BDMysql.getConnection();
  final AdafruitConn adafruitConn = AdafruitConn();
  late Future<List<dynamic>> _actuDatos;

  @override
  void initState() {
    super.initState();

    OneSignal.Notifications.addClickListener((event) {
      print(
          "Notificación clickeada: ${event.notification.jsonRepresentation()}");
      // Aquí puedes hacer que navegue a otra pantalla o muestre un mensaje
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          "Notificación recibida en primer plano: ${event.notification.jsonRepresentation()}");
      // Mostrar un mensaje en la app si está abierta
    });

    requestNotificationPermission();

    if (conn != null) {
      print(
          ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Conexión exitosa");
    }
  }

  void requestNotificationPermission() async {
    var status = await OneSignal.Notifications.requestPermission(true);
    if (status) {
      print("Permisos de notificación concedidos");
    } else {
      print("Permisos de notificación denegados");
    }
  }

  ///Registrar usuario en Firebase Firestore
  Future<void> _registerUser() async {
    try {
      // Obtener el OneSignal ID (Player ID)
      var onesignalId = await OneSignal.User.getOnesignalId();

      if (onesignalId != null) {
        // Referencia a Firestore (Colección "users")
        DocumentReference userRef =
            FirebaseFirestore.instance.collection("user").doc(onesignalId);

        // Verificar si el usuario ya existe en Firestore
        DocumentSnapshot userDoc = await userRef.get();
        if (!userDoc.exists) {
          // Crear usuario en Firestore si no existe
          await userRef.set({
            "email":
                "usuario2@example.com", // Puedes cambiar esto dinámicamente
            "contraseña": "123456", // Puedes cambiar esto dinámicamente
            "onesignal_id": onesignalId,
            "created_at": FieldValue.serverTimestamp(),
          });

          print("Usuario registrado en Firestore: $onesignalId");
        } else {
          print("ℹUsuario ya registrado en Firestore....");
        }
      } else {
        print(" No se pudo obtener el OneSignal ID.");
      }
    } catch (e) {
      print("Error al registrar usuario en Firestore: $e");
    }
  }

  /// Obtener y mostrar usuarios de Firestore en la consola
  void fetchUsers() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection("user").get();

      for (var doc in usersSnapshot.docs) {
        print("User ID: ${doc.id}");
        print("Email: ${doc["email"]}");
        print("OneSignal ID: ${doc["onesignal_id"]}");
        print(
            "--------------------------------------------------------------------------------------------");
      }
    } catch (e) {
      print(
          ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Error al obtener usuarios: $e");
    }
  }

  ///  Enviar notificación con OneSignal
  Future<void> _sendNotification() async {
    // Obtener el ID de suscripción del usuario en OneSignal
    var subscriptionId = await OneSignal.User.pushSubscription.id;
    print("ID de suscripción: $subscriptionId");
    if (subscriptionId == null) {
      print("No se encontró el OneSignal ID. Registra el dispositivo primero.");
      return;
    }

    String appId = "711694fb-4c8e-4e18-a2fa-213456646120";
    String apiKey =
        "os_v2_app_oeljj62mrzhbrix2ee2fmzdbeds6mxq2zhwunw4awadte2tgstsl4jzwiif4sjckymzzoxs6wujjdvxkdqkaxj5nmuq3ybrfxva5r4q"; // Reemplaza con tu API Key de OneSignal

    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $apiKey"
    };

    var body = jsonEncode({
      "app_id": "$appId",
      "include_player_ids": ["99ca6dec-58c8-4a7f-b583-548b166494a6"],
      "headings": {"en": "¡Hola!"},
      "contents": {"en": "Esta es una notificación de prueba."},
    });

    var response = await http.post(
      Uri.parse("https://onesignal.com/api/v1/notifications"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print(
          "Notificación>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> enviada con éxito: ${response.body}");
    } else {
      print("Error al enviar notificación: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Datos de Adafruit IO"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _actuDatos,
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
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Valor: ${data[index]['value']}"),
                subtitle: Text("Fecha: ${data[index]['created_at']}"),
              );
            },
          );
        },
      ),
    );
  }
}
