import 'package:sqflite/sqflite.dart';
import 'VoiceModel.dart';

class VoiceDBWorker{

  static final VoiceDBWorker db = VoiceDBWorker._();

  static const String DB_NAME = 'voice.db';
  static const String TBL_NAME = 'voices';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_LENGTH = 'length';
  static const String KEY_DATE = 'date';

  Database _db;

  VoiceDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_TITLE TEXT,"
                  "$KEY_LENGTH TEXT,"
                  "$KEY_DATE TEXT"
                  ")"
          );
        }
    );
  }

  @override
  Future<int> create(Voice voice) async {
    Database db = await database;
    return await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_LENGTH, $KEY_DATE) "
            "VALUES (?, ?, ?)",
        [voice.title, voice.length, voice.date]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<Voice> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _voiceFromMap(values.first);
  }

  @override
  Future<List<Voice>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _voiceFromMap(m)).toList() : [];
  }

  @override
  Future<void> update(Voice voice) async {
    Database db = await database;
    await db.update(TBL_NAME, _voiceToMap(voice),
        where: "$KEY_ID = ?", whereArgs: [voice.id]);
  }

  Voice _voiceFromMap(Map<String, dynamic> map) {
    return Voice()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..length = map[KEY_LENGTH]
      ..date = map[KEY_DATE];
  }

  Map<String, dynamic> _voiceToMap(Voice voice) {
    return Map<String, dynamic>()
      ..[KEY_ID] = voice.id
      ..[KEY_TITLE] = voice.title
      ..[KEY_LENGTH] = voice.length
      ..[KEY_DATE] = voice.date;
  }

}
