import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../widgets.dart';

/// همه کدهای خطا (اختیاری: فیلتر برند)
class ErrorListScreen extends StatefulWidget {
  final String? brandId;
  const ErrorListScreen({super.key, this.brandId});
  @override
  State<ErrorListScreen> createState() => _ErrorListScreenState();
}

class _ErrorListScreenState extends State<ErrorListScreen> {
  String _q = '';
  late final Future<List<ErrorCode>> _future = CatalogRepository.instance.errors(brandId: widget.brandId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کدهای خطا')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'جستجوی کد یا عنوان خطا... مثل E01',
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ErrorCode>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const EmptyState(icon: Icons.error_outline, title: 'خطای داخلی', message: 'در خواندن داده‌ها مشکلی پیش آمد.');
              }
              final all = snap.data ?? const [];
              final list = _q.isEmpty
                  ? all
                  : all.where((e) =>
                      e.code.toLowerCase().contains(_q) ||
                      e.title.contains(_q) ||
                      e.kw.toLowerCase().contains(_q)).toList();
              if (all.isEmpty) {
                return const EmptyState(icon: Icons.dns_outlined, title: 'دیتابیس خالی', message: 'هنوز خطایی ثبت نشده است.');
              }
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.search_off_rounded, title: 'نتیجه‌ای پیدا نشد.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final e = list[i];
                  return TyListItem(
                    leading: Container(
                      width: 48, height: 34, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: TyColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: TyColors.danger.withValues(alpha: 0.25)),
                      ),
                      child: Text(e.code,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: TyColors.danger, fontSize: 13.5)),
                    ),
                    title: e.title,
                    subtitle: e.desc,
                    trailing: LevelChip(e.level, compact: true),
                    onTap: () => Navigator.pushNamed(context, '/error', arguments: e.id),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

/// لیست مشکلات رایج یک دسته
class ProblemListScreen extends StatefulWidget {
  final String cat;
  const ProblemListScreen({super.key, required this.cat});
  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  String _q = '';
  late final Future<List<Problem>> _future = CatalogRepository.instance.problems(widget.cat);

  @override
  Widget build(BuildContext context) {
    final isPkg = widget.cat == 'pkg';
    return Scaffold(
      appBar: AppBar(title: Text(isPkg ? 'عیب‌یابی بر اساس مشکل — پکیج' : 'عیب‌یابی بر اساس مشکل — تصفیه آب')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: isPkg ? 'مثلاً: فشار کم، آب گرم نمی‌شود...' : 'مثلاً: آب خروجی کم، مخزن پر نمی‌شود...',
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Problem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const EmptyState(icon: Icons.error_outline, title: 'خطای داخلی', message: 'در خواندن داده‌ها مشکلی پیش آمد.');
              }
              final all = snap.data ?? const [];
              final list = _q.isEmpty
                  ? all
                  : all.where((p) => p.title.contains(_q) || p.kw.contains(_q) ||
                      p.causes.any((c) => c.title.contains(_q))).toList();
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.search_off_rounded, title: 'نتیجه‌ای پیدا نشد.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = list[i];
                  return TyListItem(
                    leading: CircleAvatar(
                      backgroundColor: TyColors.blue.withValues(alpha: 0.1),
                      child: Icon(isPkg ? Icons.local_fire_department_rounded : Icons.water_drop_rounded,
                          color: TyColors.blue, size: 20),
                    ),
                    title: p.title,
                    subtitle: '${p.causes.length} علت احتمالی بررسی می‌شود',
                    trailing: LevelChip(p.level, compact: true),
                    onTap: () => Navigator.pushNamed(context, '/problem', arguments: p.id),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

/// لیست قطعات
class ComponentListScreen extends StatefulWidget {
  final String? cat;
  const ComponentListScreen({super.key, this.cat});
  @override
  State<ComponentListScreen> createState() => _ComponentListScreenState();
}

class _ComponentListScreenState extends State<ComponentListScreen> {
  String _q = '';
  String? _cat;
  late final Future<List<AppComponent>> _future = CatalogRepository.instance.components(null);

  @override
  void initState() {
    super.initState();
    _cat = widget.cat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قطعات')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'جستجوی قطعه... مثل پمپ یا ممبران',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Row(children: [
            for (final f in [(null, 'همه'), ('pkg', 'قطعات پکیج'), ('ro', 'قطعات تصفیه آب')])
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(f.$2),
                  selected: _cat == f.$1,
                  onSelected: (_) => setState(() => _cat = f.$1),
                ),
              ),
          ]),
        ),
        Expanded(
          child: FutureBuilder<List<AppComponent>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const EmptyState(icon: Icons.error_outline, title: 'خطای داخلی', message: 'در خواندن داده‌ها مشکلی پیش آمد.');
              }
              var list = snap.data ?? const <AppComponent>[];
              if (_cat != null) list = list.where((c) => c.cat == _cat).toList();
              if (_q.isNotEmpty) {
                list = list.where((c) =>
                    c.name.contains(_q) || c.en.toLowerCase().contains(_q.toLowerCase()) ||
                    c.kw.contains(_q)).toList();
              }
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.search_off_rounded, title: 'نتیجه‌ای پیدا نشد.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = list[i];
                  return TyListItem(
                    leading: CircleAvatar(
                      backgroundColor: c.cat == 'pkg'
                          ? TyColors.navy.withValues(alpha: 0.08)
                          : TyColors.blue.withValues(alpha: 0.1),
                      child: Icon(
                        c.cat == 'pkg' ? Icons.settings_outlined : Icons.filter_alt_outlined,
                        color: c.cat == 'pkg' ? TyColors.navy : TyColors.blue, size: 20),
                    ),
                    title: c.name,
                    subtitle: '${c.en.isNotEmpty ? '${c.en} • ' : ''}${c.cat == 'pkg' ? 'قطعات پکیج' : 'قطعات تصفیه آب'}',
                    onTap: () => Navigator.pushNamed(context, '/component', arguments: c.id),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
