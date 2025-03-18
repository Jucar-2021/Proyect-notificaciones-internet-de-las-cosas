import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AdafruitConn {
  final String username = "jucar1992";
  final String feedTemper = "temper";
  final String feedHumedad = "humedad";
  final String feedLed = "led";
  final String apiKey = "aio_EHpC135II1FWt4twLB9XAz6tpZSn";

  Future<List<dynamic>> fetchTemper() async {
    final url = Uri.parse(
        "https://io.adafruit.com/api/v2/$username/feeds/$feedTemper/data");

    final response = await http.get(
      url,
      headers: {
        "X-AIO-Key": apiKey,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener los datos de Adafruit");
    }
  }

  Future<List<dynamic>> fetchHumedad() async {
    final url = Uri.parse(
        "https://io.adafruit.com/api/v2/$username/feeds/$feedHumedad/data");

    final response = await http.get(
      url,
      headers: {
        "X-AIO-Key": apiKey,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener los datos de Adafruit");
    }
  }

  Future<void> enviarColor(Color color) async {
    String hexColor =
        "#${color.value.toRadixString(16).substring(2).toUpperCase()}";

    final url = "https://io.adafruit.com/api/v2/$username/feeds/$feedLed/data";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "X-AIO-Key": apiKey,
        "Content-Type": "application/json",
      },
      body: '{"value": "$hexColor"}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Color enviado: $hexColor");
    } else {
      print("Error al enviar color");
    }
  }
}
