import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../widgets.dart';

/// صفحه جزئیات کد خطا
class ErrorDetailScreen extends StatefulWidget {
  final String errorId;
  const ErrorDetailScreen({super.key, required this.errorId});
  @override
  State<ErrorDetailScreen> createState() => _ErrorDetailScreenState();
}

class _ErrorDetailScreenState extends State<ErrorDetailScreen> {
  ErrorCode? _e;
  bool _missing = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    CatalogRepository.instance.error(widget.errorId).then((e) {
      if (!mounted) return;
      if (e == null) {
        setState(() => _missing = true);
      } else {
        setState(() => _e = e);
        if (!_logged) {
          _logged = true;
          AppState.instance.logHistory('error', e.id, '${e.code} — ${e.title}', 'کد خطای پکیج');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;
    return Scaffold(
      appBar: AppBar(
        title: Text(e == null ? 'جزئیات خطا' : 'خطای ${e.code}'),
        actions: [
          if (e != null) FavButton(type: 'error', id: e.id, title: '${e.code} — ${e.title}', sub: 'کد خطای پکیج'),
        ],
      ),
      body: _missing
          ? const EmptyState(icon: Icons.error_outline, title: 'اطلاعات ناقص', message: 'خطای موردنظر یافت نشد.')
          : e == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    _header(context, e),
                    const SizedBox(height: 12),
                    const SafetyCard(),
                    if (e.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _note(context, e.note),
                    ],
                    const SectionHeader('علت‌های احتمالی', icon: Icons.help_outline_rounded),
                    _numberedCard(context, e.causes),
                    const SectionHeader('مواردی که باید بررسی شوند', icon: Icons.fact_check_outlined),
                    _stepsCard(context, e.checks),
                    const SectionHeader('راهکارهای پیشنهادی', icon: Icons.handyman_outlined),
                    _numberedCard(context, e.fixes, icon: Icons.check_circle_outline_rounded),
                    const SectionHeader('قطعات مرتبط', icon: Icons.precision_manufacturing_outlined),
                    _relatedComps(context, e.comps),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _header(BuildContext context, ErrorCode e) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TyColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TyColors.danger.withValues(alpha: 0.3)),
              ),
              child: Text(e.code,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: TyColors.danger)),
            ),
            const SizedBox(width: 10),
            LevelChip(e.level),
          ]),
          const SizedBox(height: 12),
          Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          const SizedBox(height: 8),
          Text(e.desc,
              style: TextStyle(fontSize: 13.5, height: 1.8,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75))),
        ]),
      ),
    );
  }

  Widget _note(BuildContext context, String note) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TyColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TyColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: TyColors.warning, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(note, style: const TextStyle(fontSize: 12, height: 1.7))),
      ]),
    );
  }

  Widget _numberedCard(BuildContext context, List<String> items, {IconData? icon}) {
    if (items.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('اطلاعات این بخش در به‌روزرسانی بعدی تکمیل می‌شود.')));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            ListTile(
              dense: true,
              leading: icon != null
                  ? Icon(icon, color: TyColors.teal, size: 20)
                  : CircleAvatar(
                      radius: 13,
                      backgroundColor: TyColors.navy.withValues(alpha: 0.1),
                      child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: TyColors.navy)),
                    ),
              title: Text(items[i], style: const TextStyle(fontSize: 13.5, height: 1.7)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stepsCard(BuildContext context, List<CheckStep> steps) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      for (var i = 0; i < steps.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 30, height: 30, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TyColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: TyColors.teal)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(steps[i].t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 4),
                  Text(steps[i].s,
                      style: TextStyle(fontSize: 12.5, height: 1.8,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                ]),
              ),
            ]),
          ),
        ),
      ],
    ]);
  }

  Widget _relatedComps(BuildContext context, List<String> ids) {
    if (ids.isEmpty) return const Text('—');
    return FutureBuilder<List<AppComponent?>>(
      future: Future.wait(ids.map((id) => CatalogRepository.instance.component(id))),
      builder: (context, snap) {
        final list = (snap.data ?? const []).whereType<AppComponent>().toList();
        if (list.isEmpty) return const Text('—');
        return Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final c in list)
              TyChipLink(c.name,
                  onTap: () => Navigator.pushNamed(context, '/component', arguments: c.id)),
          ],
        );
      },
    );
  }
}

/// صفحه عیب‌یابی بر اساس مشکل
class ProblemDetailScreen extends StatefulWidget {
  final String problemId;
  const ProblemDetailScreen({super.key, required this.problemId});
  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  Problem? _p;
  bool _missing = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    CatalogRepository.instance.problem(widget.problemId).then((p) {
      if (!mounted) return;
      if (p == null) {
        setState(() => _missing = true);
      } else {
        setState(() => _p = p);
        if (!_logged) {
          _logged = true;
          AppState.instance.logHistory('problem', p.id, p.title, p.cat == 'pkg' ? 'عیب‌یابی پکیج' : 'عیب‌یابی تصفیه آب');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return Scaffold(
      appBar: AppBar(
        title: Text(p == null ? 'عیب‌یابی' : p.title),
        actions: [
          if (p != null)
            FavButton(type: 'problem', id: p.id, title: p.title, sub: p.cat == 'pkg' ? 'عیب‌یابی پکیج' : 'عیب‌یابی تصفیه آب'),
        ],
      ),
      body: _missing
          ? const EmptyState(icon: Icons.error_outline, title: 'اطلاعات ناقص', message: 'مشکل موردنظر یافت نشد.')
          : p == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            LevelChip(p.level),
                            const Spacer(),
                            Text('${p.causes.length} علت احتمالی',
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                          ]),
                          const SizedBox(height: 10),
                          Text(p.desc, style: const TextStyle(fontSize: 13.5, height: 1.8)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SafetyCard(),
                    const SectionHeader('علل احتمالی و بررسی گام‌به‌گام', icon: Icons.manage_search_rounded),
                    for (var i = 0; i < p.causes.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _causeCard(context, p.causes[i], i + 1),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _causeCard(BuildContext context, ProblemCause c, int index) {
    final cs = Theme.of(context).colorScheme;
    Widget row(String label, String text, IconData icon, Color color) {
      if (text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12.5, height: 1.8, color: cs.onSurface),
                children: [
                  TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ]),
      );
    }

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          initiallyExpanded: index == 1,
          leading: Container(
            width: 30, height: 30, alignment: Alignment.center,
            decoration: BoxDecoration(color: TyColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
            child: Text('$index', style: const TextStyle(fontWeight: FontWeight.w800, color: TyColors.blue)),
          ),
          title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: LevelChip(c.level, compact: true),
          ),
          children: [
            if (c.desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(c.desc,
                    style: TextStyle(fontSize: 12.5, height: 1.8, color: cs.onSurface.withValues(alpha: 0.8))),
              ),
            row('نشانه‌ها', c.signs, Icons.visibility_outlined, TyColors.blue),
            row('روش بررسی', c.check, Icons.fact_check_outlined, TyColors.warning),
            row('راهکار', c.fix, Icons.handyman_outlined, TyColors.success),
            if (c.comps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    for (final id in c.comps)
                      FutureBuilder<AppComponent?>(
                        future: CatalogRepository.instance.component(id),
                        builder: (context, snap) {
                          final comp = snap.data;
                          if (comp == null) return const SizedBox.shrink();
                          return TyChipLink(comp.name,
                              onTap: () => Navigator.pushNamed(context, '/component', arguments: comp.id));
                        },
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// صفحه جزئیات قطعه
class ComponentDetailScreen extends StatefulWidget {
  final String componentId;
  const ComponentDetailScreen({super.key, required this.componentId});
  @override
  State<ComponentDetailScreen> createState() => _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends State<ComponentDetailScreen> {
  AppComponent? _c;
  bool _missing = false;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    CatalogRepository.instance.component(widget.componentId).then((c) {
      if (!mounted) return;
      if (c == null) {
        setState(() => _missing = true);
      } else {
        setState(() => _c = c);
        if (!_logged) {
          _logged = true;
          AppState.instance.logHistory('component', c.id, c.name, c.cat == 'pkg' ? 'قطعات پکیج' : 'قطعات تصفیه آب');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      appBar: AppBar(
        title: Text(c == null ? 'قطعه' : c.name),
        actions: [
          if (c != null)
            FavButton(type: 'component', id: c.id, title: c.name, sub: c.cat == 'pkg' ? 'قطعات پکیج' : 'قطعات تصفیه آب'),
        ],
      ),
      body: _missing
          ? const EmptyState(icon: Icons.error_outline, title: 'اطلاعات ناقص', message: 'قطعه موردنظر یافت نشد.')
          : c == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: TyColors.navy.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(c.cat == 'pkg' ? Icons.settings_outlined : Icons.filter_alt_outlined,
                                color: TyColors.navy, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                              if (c.en.isNotEmpty)
                                Text(c.en, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                              Text(c.cat == 'pkg' ? 'قطعات پکیج' : 'قطعات تصفیه آب',
                                  style: const TextStyle(fontSize: 11.5, color: TyColors.teal, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                    const SectionHeader('وظیفه قطعه', icon: Icons.info_outline_rounded),
                    _textCard(context, c.func),
                    const SectionHeader('علائم خرابی', icon: Icons.warning_amber_rounded),
                    _bulletCard(context, c.signs),
                    const SectionHeader('روش بررسی', icon: Icons.fact_check_outlined),
                    _bulletCard(context, c.check),
                    if (c.errors.isNotEmpty) ...[
                      const SectionHeader('کدهای خطای مرتبط', icon: Icons.error_outline_rounded),
                      _relatedErrors(context, c.errors),
                    ],
                    if (c.problems.isNotEmpty) ...[
                      const SectionHeader('مشکلات مرتبط', icon: Icons.build_circle_outlined),
                      _relatedProblems(context, c.problems),
                    ],
                    const SizedBox(height: 16),
                    const SafetyCard(),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _textCard(BuildContext context, String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text.isEmpty ? 'اطلاعات این بخش در به‌روزرسانی بعدی تکمیل می‌شود.' : text,
            style: const TextStyle(fontSize: 13, height: 1.9)),
      ),
    );
  }

  Widget _bulletCard(BuildContext context, List<String> items) {
    if (items.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('—')));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: [
          for (var i = 0; i < items.length; i++)
            ListTile(
              dense: true,
              leading: const Icon(Icons.circle, size: 8, color: TyColors.teal),
              title: Text(items[i], style: const TextStyle(fontSize: 13, height: 1.7)),
            ),
        ]),
      ),
    );
  }

  Widget _relatedErrors(BuildContext context, List<String> codes) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        for (final code in codes)
          TyChipLink('خطای $code',
              onTap: () => Navigator.pushNamed(context, '/error', arguments: 'err-${code.toLowerCase()}')),
      ],
    );
  }

  Widget _relatedProblems(BuildContext context, List<String> ids) {
    return FutureBuilder<List<Problem?>>(
      future: Future.wait(ids.map((id) => CatalogRepository.instance.problem(id))),
      builder: (context, snap) {
        final list = (snap.data ?? const []).whereType<Problem>().toList();
        if (list.isEmpty) return const Text('—');
        return Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final p in list)
              TyChipLink(p.title,
                  onTap: () => Navigator.pushNamed(context, '/problem', arguments: p.id)),
          ],
        );
      },
    );
  }
}
