import 'dart:convert';
import 'package:http/http.dart' as http;

class AdafruitConn {
  final String username = "jucar1992";
  final String feedName = "temper";
  final String apiKey = "aio_jAIt55ZEjzX1slcsVe40ZZ3TWyKI";

  Future<List<dynamic>> fetchData() async {
    final url = Uri.parse(
        "https://io.adafruit.com/api/v2/$username/feeds/$feedName/data");

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
}
