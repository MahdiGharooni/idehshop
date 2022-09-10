import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const String FAVORITE_SHOPS = 'favoriteShops';

class DataBaseManager {
  Database _db;

  Future open() async {
    final directory = await getApplicationDocumentsDirectory();
    String part1 = directory.path;
    await SharedPreferences.getInstance().then((preferences) async {
      String part2 = 'idehshop.db';
      String path = join(part1, part2);
      _db = await openDatabase(
        path,
        onCreate: (Database _db, int version) async {
          await _db.execute(
              "CREATE TABLE $FAVORITE_SHOPS (id TEXT PRIMARY KEY, favorite INTEGER)");
        },
        version: 2,
      );
    });
  }

  /// favorite shops table related functions
  Future<dynamic> createFavoriteShop(String id, int favorite) async {
    return await _db.insert(
      FAVORITE_SHOPS,
      {
        "id": id,
        "favorite": favorite,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> readFavoriteShop(String id) async {
    return await _db.transaction((txn) async {
      dynamic competitions = await txn.query(
        FAVORITE_SHOPS,
        where: "id = ?",
        whereArgs: [id],
      );
      return competitions.isNotEmpty ? competitions[0] : {};
    });
  }



  Future close() async => _db.close();
}
