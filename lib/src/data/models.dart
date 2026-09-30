import 'dart:convert';

String _str(dynamic v) => v?.toString() ?? '';
List<String> _strList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];

class Brand {
  final String id, cat, name, en, desc;
  final bool sample;
  final int deviceCount;
  const Brand({
    required this.id, required this.cat, required this.name,
    this.en = '', this.desc = '', this.sample = false, this.deviceCount = 0,
  });
  factory Brand.fromJson(Map<String, dynamic> j) => Brand(
        id: _str(j['id']), cat: _str(j['cat']), name: _str(j['name']),
        en: _str(j['en']), desc: _str(j['desc']), sample: j['sample'] == true,
      );
}

class Device {
  final String id, brand, cat, model, type, cap, desc;
  final bool sample;
  final String? brandName;
  const Device({
    required this.id, required this.brand, required this.cat, required this.model,
    this.type = '', this.cap = '', this.desc = '', this.sample = false, this.brandName,
  });
  String get displayName => brandName != null ? '$brandName $model' : model;
  factory Device.fromJson(Map<String, dynamic> j) => Device(
        id: _str(j['id']), brand: _str(j['brand']), cat: _str(j['cat']),
        model: _str(j['model']), type: _str(j['type']), cap: _str(j['cap']),
        desc: _str(j['desc']), sample: j['sample'] == true,
      );
}

class CheckStep {
  final String t, s;
  const CheckStep(this.t, this.s);
  factory CheckStep.fromJson(Map<String, dynamic> j) => CheckStep(_str(j['t']), _str(j['s']));
}

class ErrorCode {
  final String id, code, title, cat, desc, level, kw, note;
  final List<String> brands, causes, fixes, comps;
  final List<CheckStep> checks;
  const ErrorCode({
    required this.id, required this.code, required this.title,
    this.cat = 'pkg', this.desc = '', this.level = 'med', this.kw = '', this.note = '',
    this.brands = const [], this.causes = const [], this.fixes = const [],
    this.comps = const [], this.checks = const [],
  });
  factory ErrorCode.fromJson(Map<String, dynamic> j) => ErrorCode(
        id: _str(j['id']), code: _str(j['code']), title: _str(j['title']),
        cat: _str(j['cat']), desc: _str(j['desc']), level: _str(j['level']),
        kw: _str(j['kw']), note: _str(j['note']),
        brands: _strList(j['brands']), causes: _strList(j['causes']),
        fixes: _strList(j['fixes']), comps: _strList(j['comps']),
        checks: j['checks'] is List
            ? (j['checks'] as List).map((e) => CheckStep.fromJson(Map<String, dynamic>.from(e))).toList()
            : const [],
      );
}

class ProblemCause {
  final String title, desc, signs, check, fix, level;
  final List<String> comps;
  const ProblemCause({
    required this.title, this.desc = '', this.signs = '', this.check = '',
    this.fix = '', this.level = 'med', this.comps = const [],
  });
  factory ProblemCause.fromJson(Map<String, dynamic> j) => ProblemCause(
        title: _str(j['title']), desc: _str(j['desc']), signs: _str(j['signs']),
        check: _str(j['check']), fix: _str(j['fix']), level: _str(j['level']),
        comps: _strList(j['comps']),
      );
}

class Problem {
  final String id, cat, title, desc, level, kw;
  final List<ProblemCause> causes;
  const Problem({
    required this.id, required this.cat, required this.title,
    this.desc = '', this.level = 'med', this.kw = '', this.causes = const [],
  });
  factory Problem.fromJson(Map<String, dynamic> j) => Problem(
        id: _str(j['id']), cat: _str(j['cat']), title: _str(j['title']),
        desc: _str(j['desc']), level: _str(j['level']), kw: _str(j['kw']),
        causes: j['causes'] is List
            ? (j['causes'] as List).map((e) => ProblemCause.fromJson(Map<String, dynamic>.from(e))).toList()
            : const [],
      );
}

class AppComponent {
  final String id, cat, name, en, func, kw;
  final List<String> signs, check, problems, errors;
  const AppComponent({
    required this.id, required this.cat, required this.name,
    this.en = '', this.func = '', this.kw = '',
    this.signs = const [], this.check = const [],
    this.problems = const [], this.errors = const [],
  });
  factory AppComponent.fromJson(Map<String, dynamic> j) => AppComponent(
        id: _str(j['id']), cat: _str(j['cat']), name: _str(j['name']),
        en: _str(j['en']), func: _str(j['func']), kw: _str(j['kw']),
        signs: _strList(j['signs']), check: _strList(j['check']),
        problems: _strList(j['problems']), errors: _strList(j['errors']),
      );
}

class SearchHit {
  final String type, id, title, sub;
  const SearchHit({required this.type, required this.id, required this.title, this.sub = ''});
  factory SearchHit.fromMap(Map<String, Object?> m) => SearchHit(
        type: _str(m['type']), id: _str(m['item_id']),
        title: _str(m['title']), sub: _str(m['sub']),
      );
}

class UserItem {
  final String type, id, title, sub;
  final int at;
  const UserItem({required this.type, required this.id, required this.title, this.sub = '', this.at = 0});
  factory UserItem.fromMap(Map<String, Object?> m) => UserItem(
        type: _str(m['item_type']), id: _str(m['item_id']),
        title: _str(m['title']), sub: _str(m['sub']),
        at: (m['added_at'] ?? m['viewed_at']) is int ? ((m['added_at'] ?? m['viewed_at']) as int) : 0,
      );
}

String encodeList(List<String> v) => jsonEncode(v);
List<String> decodeList(Object? v) {
  if (v == null) return const [];
  try {
    final d = jsonDecode(v.toString());
    return d is List ? d.map((e) => e.toString()).toList() : const [];
  } catch (_) {
    return const [];
  }
}
