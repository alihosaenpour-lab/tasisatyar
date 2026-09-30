import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// دیتابیس محلی تأسیسات‌یار — کاملاً آفلاین.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'tasisatyar.db';
  static const _dbVersion = 1;

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async => _createSchema(db),
      onOpen: (db) async => _seedIfNeeded(db),
    );
    await _seedIfNeeded(_db!);
  }

  Future<void> _createSchema(Database d) async {
    await d.execute('CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT)');
    await d.execute('''CREATE TABLE IF NOT EXISTS brands(
        id TEXT PRIMARY KEY, cat TEXT, name TEXT, en TEXT, desc TEXT, sample INTEGER)''');
    await d.execute('''CREATE TABLE IF NOT EXISTS devices(
        id TEXT PRIMARY KEY, brand TEXT, cat TEXT, model TEXT, type TEXT, cap TEXT, desc TEXT, sample INTEGER)''');
    await d.execute('''CREATE TABLE IF NOT EXISTS error_codes(
        id TEXT PRIMARY KEY, code TEXT, title TEXT, cat TEXT, brands_json TEXT, desc TEXT,
        level TEXT, causes_json TEXT, checks_json TEXT, fixes_json TEXT, comps_json TEXT, kw TEXT, note TEXT)''');
    await d.execute('''CREATE TABLE IF NOT EXISTS problems(
        id TEXT PRIMARY KEY, cat TEXT, title TEXT, desc TEXT, level TEXT, kw TEXT, causes_json TEXT)''');
    await d.execute('''CREATE TABLE IF NOT EXISTS components(
        id TEXT PRIMARY KEY, cat TEXT, name TEXT, en TEXT, func TEXT, signs_json TEXT,
        check_json TEXT, kw TEXT, problems_json TEXT, errors_json TEXT)''');
    await d.execute('''CREATE TABLE IF NOT EXISTS favorites(
        item_type TEXT, item_id TEXT, title TEXT, sub TEXT, added_at INTEGER,
        PRIMARY KEY(item_type, item_id))''');
    await d.execute('''CREATE TABLE IF NOT EXISTS history(
        item_type TEXT, item_id TEXT, title TEXT, sub TEXT, viewed_at INTEGER,
        PRIMARY KEY(item_type, item_id))''');
    // ایندکس جستجوی تمام‌متن (سریع حتی با دیتای زیاد)
    try {
      await d.execute('''CREATE VIRTUAL TABLE IF NOT EXISTS search_fts USING fts5(
          text, type UNINDEXED, item_id UNINDEXED, title UNINDEXED, sub UNINDEXED,
          tokenize='unicode61')''');
    } catch (_) {/* FTS5 در دسترس نبود — جستجو با LIKE انجام می‌شود */}
    await d.execute('CREATE INDEX IF NOT EXISTS idx_errors_code ON error_codes(code)');
    await d.execute('CREATE INDEX IF NOT EXISTS idx_devices_brand ON devices(brand)');
    await d.execute('CREATE INDEX IF NOT EXISTS idx_problems_cat ON problems(cat)');
  }

  Future<void> _seedIfNeeded(Database d) async {
    final raw = await rootBundle.loadString('assets/data/seed.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final meta = Map<String, dynamic>.from(j['meta'] as Map);
    final version = (meta['db_version'] ?? '0').toString();
    final row = await d.query('meta', where: 'key=?', whereArgs: ['seed_version']);
    final current = row.isNotEmpty ? row.first['value']?.toString() : null;
    if (current == version) return;

    await d.transaction((txn) async {
      for (final t in ['brands', 'devices', 'error_codes', 'problems', 'components']) {
        await txn.delete(t);
      }
      try { await txn.delete('search_fts'); } catch (_) {}

      Future<void> batch(String table, List<Map<String, Object?>> rows) async {
        final b = txn.batch();
        for (final r in rows) {
          b.insert(table, r, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await b.commit(noResult: true);
      }

      await batch('brands', [
        for (final e in j['brands'] as List)
          {
            'id': e['id'], 'cat': e['cat'], 'name': e['name'],
            'en': e['en'] ?? '', 'desc': e['desc'] ?? '',
            'sample': (e['sample'] == true) ? 1 : 0,
          }
      ]);
      await batch('devices', [
        for (final e in j['devices'] as List)
          {
            'id': e['id'], 'brand': e['brand'], 'cat': e['cat'],
            'model': e['model'], 'type': e['type'] ?? '', 'cap': e['cap'] ?? '',
            'desc': e['desc'] ?? '', 'sample': (e['sample'] == true) ? 1 : 0,
          }
      ]);
      await batch('error_codes', [
        for (final e in j['errors'] as List)
          {
            'id': e['id'], 'code': e['code'], 'title': e['title'], 'cat': e['cat'],
            'brands_json': jsonEncode(e['brands'] ?? []),
            'desc': e['desc'] ?? '', 'level': e['level'] ?? 'med',
            'causes_json': jsonEncode(e['causes'] ?? []),
            'checks_json': jsonEncode(e['checks'] ?? []),
            'fixes_json': jsonEncode(e['fixes'] ?? []),
            'comps_json': jsonEncode(e['comps'] ?? []),
            'kw': e['kw'] ?? '', 'note': e['note'] ?? '',
          }
      ]);
      await batch('problems', [
        for (final e in j['problems'] as List)
          {
            'id': e['id'], 'cat': e['cat'], 'title': e['title'],
            'desc': e['desc'] ?? '', 'level': e['level'] ?? 'med',
            'kw': e['kw'] ?? '', 'causes_json': jsonEncode(e['causes'] ?? []),
          }
      ]);
      await batch('components', [
        for (final e in j['components'] as List)
          {
            'id': e['id'], 'cat': e['cat'], 'name': e['name'], 'en': e['en'] ?? '',
            'func': e['func'] ?? '', 'signs_json': jsonEncode(e['signs'] ?? []),
            'check_json': jsonEncode(e['check'] ?? []), 'kw': e['kw'] ?? '',
            'problems_json': jsonEncode(e['problems'] ?? []),
            'errors_json': jsonEncode(e['errors'] ?? []),
          }
      ]);
      try {
        final b = txn.batch();
        for (final s in j['search_index'] as List) {
          b.insert('search_fts', {
            'text': '${s['title']} ${s['sub'] ?? ''} ${s['text'] ?? ''}',
            'type': s['t'], 'item_id': s['id'],
            'title': s['title'], 'sub': s['sub'] ?? '',
          });
        }
        await b.commit(noResult: true);
      } catch (_) {}
      await txn.insert('meta', {'key': 'seed_version', 'value': version},
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('meta', {'key': 'db_version_label', 'value': meta['updated'] ?? ''},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
