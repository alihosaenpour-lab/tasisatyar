import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/repository.dart';
import '../shell.dart';
import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _dbInfo = 'نسخه اطلاعاتی ۱٫۰';
  String _dbUpdated = '';

  @override
  void initState() {
    super.initState();
    CatalogRepository.instance.meta('seed_version', fallback: '1.0.0').then((v) {
      CatalogRepository.instance.meta('db_version_label').then((u) {
        if (mounted) setState(() {
          _dbInfo = 'نسخه اطلاعاتی $v';
          _dbUpdated = u;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TyTabScaffold(
      tab: 0,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _header(context),
            const SizedBox(height: 16),
            _searchBar(context),
            const SectionHeader('دسته‌های اصلی'),
            _categoryCards(context),
            const SectionHeader('دسترسی سریع'),
            _quickAccess(context),
            const SizedBox(height: 24),
            _dbFooter(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(children: [
        Hero(
          tag: 'ty-logo',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/images/logo.png', width: 52, height: 52),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('تأسیسات‌یار',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text('آرشیو تخصصی عیب‌یابی و تعمیرات',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ]),
        ),
        IconButton(
          tooltip: 'تنظیمات',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ]),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(children: [
            const Icon(Icons.search_rounded, color: TyColors.teal, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text('کد خطا، مدل دستگاه یا مشکل خود را جستجو کنید...',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 14)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _categoryCards(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _catCard(context,
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFE07020),
              title: 'پکیج',
              subtitle: 'خطاها، مشکلات و عیب‌یابی پکیج',
              route: '/pkg')),
      const SizedBox(width: 12),
      Expanded(
          child: _catCard(context,
              icon: Icons.water_drop_rounded,
              color: TyColors.blue,
              title: 'تصفیه آب',
              subtitle: 'مشکلات، قطعات و عیب‌یابی دستگاه تصفیه آب',
              route: '/ro')),
    ]);
  }

  Widget _catCard(BuildContext context,
      {required IconData icon, required Color color, required String title,
       required String subtitle, required String route}) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11.5, height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
            const SizedBox(height: 10),
            Row(children: [
              Text('مشاهده', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
              Icon(Icons.arrow_back_rounded, size: 15, color: color),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _quickAccess(BuildContext context) {
    final items = <(IconData, Color, String, String, Object?)>[
      (Icons.manage_search_rounded, TyColors.teal, 'جستجوی سریع', '/search', null),
      (Icons.error_outline_rounded, TyColors.danger, 'همه خطاها', '/errors', null),
      (Icons.precision_manufacturing_outlined, TyColors.blue, 'قطعات', '/components', null),
      (Icons.star_outline_rounded, TyColors.warning, 'ذخیره‌شده‌ها', '/favorites', null),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        for (final it in items)
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, it.$4, arguments: it.$5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(it.$1, color: it.$2, size: 26),
                const SizedBox(height: 8),
                Text(it.$3, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _dbFooter(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.dns_outlined, size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('آخرین به‌روزرسانی بانک اطلاعاتی: $_dbUpdated',
              style: TextStyle(fontSize: 11.5, color: cs.onSurface.withValues(alpha: 0.55))),
        ),
        Text(_dbInfo, style: const TextStyle(fontSize: 11.5, color: TyColors.teal, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
