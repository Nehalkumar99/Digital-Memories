import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tablename = 'localTable';
final String idColumn = 'idColumn';
final String descriptionCol = 'description';
final String pathCol = 'path';
final String texturlCol = 'texturl';
final String timeCol = 'time';
final String filetypeCol = 'filetype';
final String thumbnailCol = 'thumbnail';

class DetailsHelper {
  static final DetailsHelper _instance = DetailsHelper.internal();
  factory DetailsHelper() => _instance;
  DetailsHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'detailssnew.db');
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute('CREATE TABLE $tablename('
          '$idColumn INTEGER PRIMARY KEY,'
          '$descriptionCol TEXT,'
          '$pathCol TEXT,'
          '$texturlCol TEXT,'
          '$timeCol TEXT,'
          '$filetypeCol TEXT,'
          '$thumbnailCol TEXT )');
    });
  }

  Future<Details> savedetails(Details details) async {
    var dbdetails = await db;
    details.id = await dbdetails.insert(tablename, details.toMap());
    return details;
  }

  Future<Details> getdetails(int id) async {
    var dbdetails = await db;
    List<Map> maps = await dbdetails.query(tablename,
        columns: [
          idColumn,
          descriptionCol,
          pathCol,
          texturlCol,
          timeCol,
          filetypeCol,
          thumbnailCol
        ],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Details.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletedetails(int id) async {
    var dbdetails = await db;
    return await dbdetails
        .delete(tablename, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updatedetails(Details details) async {
    var dbdetails = await db;
    return await dbdetails.update(tablename, details.toMap(),
        where: '$idColumn = ?', whereArgs: [details.id]);
  }

  Future<List> getAlldetailss() async {
    var dbdetails = await db;
    List listMap = await dbdetails.rawQuery('SELECT * FROM $tablename');
    var listdetails = <Details>[];
    for (Map m in listMap) {
      listdetails.add(Details.fromMap(m));
    }
    return listdetails;
  }

  Future<int> getNumber() async {
    var dbdetails = await db;
    return Sqflite.firstIntValue(
        await dbdetails.rawQuery('SELECT COUNT(*) FROM $tablename'));
  }

  Future close() async {
    var dbdetails = await db;
    dbdetails.close();
  }
}

class Details {
  int id;
  String description;
  String path;
  String texturl;
  String time;
  String filetype;
  String thumbnail;

  Details();

  Details.fromMap(Map map) {
    id = map[idColumn];
    description = map[descriptionCol];
    path = map[pathCol];
    texturl = map[texturlCol];
    time = map[timeCol];
    filetype = map[filetypeCol];
    thumbnail = map[thumbnailCol];
  }

  Map toMap() {
    var map = <String, dynamic>{
      descriptionCol: description,
      pathCol: path,
      texturlCol: texturl,
      timeCol: time,
      filetypeCol: filetype,
      thumbnailCol: thumbnail
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Details('
        'id: $id,'
        'description: $description, '
        'path: $path, '
        'texturl: $texturl, '
        'time: $time,'
        'thumbnail" $thumbnail,'
        'filetype: $filetype)';
  }
}
