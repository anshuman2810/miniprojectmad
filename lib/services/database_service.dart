import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/colorized_image.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'colorization_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE colorized_images('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'originalPath TEXT, '
              'colorizedPath TEXT, '
              'createdAt TEXT'
              ')',
        );
      },
    );
  }

  Future<int> insertColorizedImage(ColorizedImage colorizedImage) async {
    final db = await database;
    return await db.insert('colorized_images', colorizedImage.toMap());
  }

  Future<List<ColorizedImage>> getColorizedImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'colorized_images',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return ColorizedImage.fromMap(maps[i]);
    });
  }

  Future<ColorizedImage?> getColorizedImage(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'colorized_images',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ColorizedImage.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteColorizedImage(int id) async {
    final db = await database;
    return await db.delete(
      'colorized_images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}