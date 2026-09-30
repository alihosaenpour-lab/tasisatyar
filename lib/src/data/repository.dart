import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'models.dart';

/// لایه دسترسی به داده — تمام کوئری‌های اپ این‌جاست (جداسازی داده از UI).
class CatalogRepository {
  CatalogRepository._();
  static final CatalogRepository instance = CatalogRepository._();

  Database get _db => AppDatabase.instance.db;

  // ---------- کاتالوگ ----------
  Future<List<Brand>> brands(String cat) async {
    final rows = await _db.rawQuery('''
      SELECT b.*, (SELECT COUNT(*) FROM devices d WHERE d.brand = b.id) AS dc
      FROM brands b WHERE b.cat = ? ORDER BY b.name COLLATE NOCASE''', [cat]);
    return [
      for (final r in rows)
        Brand(
          id: r['id'] as String, cat: r['cat'] as String, name: r['name'] as String,
          en: r['en'] as String? ?? '', desc: r['desc'] as String? ?? '',
          sample: r['sample'] == 1, deviceCount: r['dc'] as int? ?? 0,
        )
    ];
  }

  Future<Brand?> brand(String id) async {
    final r = await _db.query('brands', where: 'id=?', whereArgs: [id]);
    if (r.isEmpty) return null;
    final e = r.first;
    return Brand(id: e['id'] as String, cat: e['cat'] as String, name: e['name'] as String,
        en: e['en'] as String? ?? '', desc: e['desc'] as String? ?? '', sample: e['sample'] == 1);
  }

  Future<List<Device>> devicesOf(String brandId) async {
    final rows = await _db.query('devices', where: 'brand=?', whereArgs: [brandId], orderBy: 'model');
    final b = await brand(brandId);
    return [
      for (final r in rows)
        Device(id: r['id'] as String, brand: r['brand'] as String, cat: r['cat'] as String,
            model: r['model'] as String, type: r['type'] as String? ?? '',
            cap: r['cap'] as String? ?? '', desc: r['desc'] as String? ?? '',
            sample: r['sample'] == 1, brandName: b?.name)
    ];
  }

  Future<Device?> device(String id) async {
    final r = await _db.query('devices', where: 'id=?', whereArgs: [id]);
    if (r.isEmpty) return null;
    final e = r.first;
    final b = await brand(e['brand'] as String);
    return Device(id: e['id'] as String, brand: e['brand'] as String, cat: e['cat'] as String,
        model: e['model'] as String, type: e['type'] as String? ?? '',
        cap: e['cap'] as String? ?? '', desc: e['desc'] as String? ?? '',
        sample: e['sample'] == 1, brandName: b?.name);
  }

  // ---------- خطاها ----------
  Future<List<ErrorCode>> errors({String? brandId}) async {
    final rows = await _db.query('error_codes', orderBy: 'code');
    final list = [for (final r in rows) _errorFromRow(r)];
    if (brandId == null) return list;
    return list.where((e) => e.brands.contains('all') || e.brands.contains(brandId)).toList();
  }

  ErrorCode _errorFromRow(Map<String, Object?> r) => ErrorCode(
        id: r['id'] as String, code: r['code'] as String, title: r['title'] as String,
        cat: r['cat'] as String? ?? 'pkg', desc: r['desc'] as String? ?? '',
        level: r['level'] as String? ?? 'med', kw: r['kw'] as String? ?? '',
        note: r['note'] as String? ?? '',
        brands: decodeList(r['brands_json']), causes: decodeList(r['causes_json']),
        fixes: decodeList(r['fixes_json']), comps: decodeList(r['comps_json']),
        checks: [
          for (final c in _decodeMapList(r['checks_json'])) CheckStep(c['t'] ?? '', c['s'] ?? '')
        ],
      );

  Future<ErrorCode?> error(String id) async {
    final r = await _db.query('error_codes', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : _errorFromRow(r.first);
  }

  // ---------- مشکلات ----------
  Future<List<Problem>> problems(String cat) async {
    final rows = await _db.query('problems', where: 'cat=?', whereArgs: [cat], orderBy: 'title');
    return [for (final r in rows) _problemFromRow(r)];
  }

  Problem _problemFromRow(Map<String, Object?> r) => Problem(
        id: r['id'] as String, cat: r['cat'] as String, title: r['title'] as String,
        desc: r['desc'] as String? ?? '', level: r['level'] as String? ?? 'med',
        kw: r['kw'] as String? ?? '',
        causes: [
          for (final c in _decodeMapList(r['causes_json']))
            ProblemCause(
              title: c['title'] ?? '', desc: c['desc'] ?? '', signs: c['signs'] ?? '',
              check: c['check'] ?? '', fix: c['fix'] ?? '', level: c['level'] ?? 'med',
              comps: c['comps'] is List ? [for (final x in c['comps'] as List) x.toString()] : const [],
            )
        ],
      );

  Future<Problem?> problem(String id) async {
    final r = await _db.query('problems', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : _problemFromRow(r.first);
  }

  // ---------- قطعات ----------
  Future<List<AppComponent>> components(String? cat) async {
    final rows = cat == null
        ? await _db.query('components', orderBy: 'name')
        : await _db.query('components', where: 'cat=?', whereArgs: [cat], orderBy: 'name');
    return [for (final r in rows) _compFromRow(r)];
  }

  AppComponent _compFromRow(Map<String, Object?> r) => AppComponent(
        id: r['id'] as String, cat: r['cat'] as String, name: r['name'] as String,
        en: r['en'] as String? ?? '', func: r['func'] as String? ?? '',
        kw: r['kw'] as String? ?? '',
        signs: decodeList(r['signs_json']), check: decodeList(r['check_json']),
        problems: decodeList(r['problems_json']), errors: decodeList(r['errors_json']),
      );

  Future<AppComponent?> component(String id) async {
    final r = await _db.query('components', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : _compFromRow(r.first);
  }

  List<Map<String, String>> _decodeMapList(Object? v) {
    if (v == null) return const [];
    try {
      final d = jsonDecode(v.toString());
      return d is List
          ? [for (final e in d) (e as Map).map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''))]
          : const [];
    } catch (_) {
      return const [];
    }
  }

  // ---------- جستجو ----------
  Future<List<SearchHit>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    // ۱) FTS5
    try {
      final terms = q
          .replaceAll(RegExp(r'["\*\-\(\):]'), ' ')
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty)
          .map((t) => '$t*')
          .toList();
      if (terms.isNotEmpty) {
        final match = terms.join(' ');
        final rows = await _db.rawQuery(
            'SELECT type, item_id, title, sub FROM search_fts WHERE search_fts MATCH ? LIMIT 60',
            [match]);
        if (rows.isNotEmpty) return [for (final r in rows) SearchHit.fromMap(r)];
      }
    } catch (_) {/* fallback */}
    // ۲) LIKE (fallback)
    final like = '%$q%';
    final rows = await _db.rawQuery(
        'SELECT type, item_id, title, sub FROM search_fts WHERE text LIKE ? OR title LIKE ? LIMIT 60',
        [like, like]);
    return [for (final r in rows) SearchHit.fromMap(r)];
  }

  // ---------- علاقه‌مندی‌ها ----------
  Future<void> setFavorite(String type, String id, String title, String sub, bool fav) async {
    if (fav) {
      await _db.insert(
          'favorites',
          {'item_type': type, 'item_id': id, 'title': title, 'sub': sub,
           'added_at': DateTime.now().millisecondsSinceEpoch},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await _db.delete('favorites', where: 'item_type=? AND item_id=?', whereArgs: [type, id]);
    }
  }

  Future<Set<String>> favoriteKeys() async {
    final rows = await _db.query('favorites');
    return {for (final r in rows) '${r['item_type']}:${r['item_id']}'};
  }

  Future<List<UserItem>> favorites() async {
    final rows = await _db.query('favorites', orderBy: 'added_at DESC');
    return [for (final r in rows) UserItem.fromMap(r)];
  }

  // ---------- تاریخچه ----------
  Future<void> logHistory(String type, String id, String title, String sub) async {
    await _db.insert(
        'history',
        {'item_type': type, 'item_id': id, 'title': title, 'sub': sub,
         'viewed_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace);
    // نگه‌داشتن حداکثر ۵۰ مورد
    await _db.rawDelete(
        'DELETE FROM history WHERE (item_type || item_id) NOT IN '
        '(SELECT (item_type || item_id) FROM history ORDER BY viewed_at DESC LIMIT 50)');
  }

  Future<List<UserItem>> history() async {
    final rows = await _db.query('history', orderBy: 'viewed_at DESC', limit: 50);
    return [for (final r in rows) UserItem.fromMap(r)];
  }

  Future<void> clearHistory() async => _db.delete('history');

  // ---------- متادیتا ----------
  Future<String> meta(String key, {String fallback = ''}) async {
    final r = await _db.query('meta', where: 'key=?', whereArgs: [key]);
    return r.isEmpty ? fallback : (r.first['value']?.toString() ?? fallback);
  }
}
