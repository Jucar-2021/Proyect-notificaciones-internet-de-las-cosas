import 'package:mysql1/mysql1.dart';

class BDMysql {
  static Future<MySqlConnection> getConnection() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'mysql-carlos08.alwaysdata.net',
      port: 3306,
      db: 'carlos08_actividadfinal',
      user: 'carlos08',
      password: 'carlosunideh',
    ));

    return conn;
  }

  Future<List<Map<String, dynamic>>> select() async {
    final conn = await getConnection();

    try {
      final results = await conn.query(
          'SELECT tem, humeda, fecha FROM temperatura ORDER BY id DESC LIMIT 10');

      final List<Map<String, dynamic>> lista = [];

      for (var row in results) {
        lista.add({
          'tem': row['tem'].toString(),
          'humeda': row['humeda'].toString(),
          'fecha': row['fecha'].toString(),
        });
      }

      return lista;
    } catch (e) {
      print("Error al obtener datos: $e");
      return [];
    } finally {
      await conn.close();
    }
  }

  Future insert(double tem, double humedad) async {
    try {
      final conn = await getConnection();
      await conn.query(
          'INSERT INTO temperatura (tem,humeda,fecha) VALUES (?,?,?)',
          [tem, humedad, DateTime.now().toString()]);
      await conn.close();
    } catch (e) {
      print('Error al insertar datos: $e');
    }
  }
}
