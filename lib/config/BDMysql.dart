import 'package:mysql1/mysql1.dart';

class BDMysql {
  static final BDMysql _instance = BDMysql._internal();

  factory BDMysql() => _instance;

  BDMysql._internal();

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

  Future update() async {}
}
