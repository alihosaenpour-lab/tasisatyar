import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../shell.dart';
import '../widgets.dart';

/// هاب دسته‌بندی: پکیج یا تصفیه آب
class CategoryScreen extends StatelessWidget {
  final String cat;
  const CategoryScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final isPkg = cat == 'pkg';
    final color = isPkg ? const Color(0xFFE07020) : TyColors.blue;
    final entries = <(IconData, Color, String, String, String, Object?)>[
      (Icons.factory_outlined, color, 'برندها', 'مشاهده برندها و مدل‌ها', '/brands', cat),
      (Icons.devices_other_rounded, color, 'مدل‌ها', 'مدل‌های شناخته‌شده', '/brands', cat),
      if (isPkg)
        (Icons.error_outline_rounded, TyColors.danger, 'کدهای خطا', 'جستجو بر اساس کد خطا مانند E01', '/errors', null),
      (Icons.build_circle_outlined, TyColors.blue, 'مشکلات رایج', isPkg ? 'عیب‌یابی علامت‌محور پکیج' : 'عیب‌یابی علامت‌محور دستگاه', '/problems', cat),
      (Icons.precision_manufacturing_outlined, TyColors.teal, 'قطعات', 'شناخت، وظیفه و روش بررسی قطعات', '/components', cat),
      (Icons.route_outlined, TyColors.warning, 'راهنمای عیب‌یابی', 'مسیر گام‌به‌گام تشخیص', '/guide', cat),
    ];
    return TyTabScaffold(
      tab: isPkg ? 2 : 3,
      appBar: AppBar(
        title: Text(isPkg ? 'پکیج' : 'تصفیه آب'),
        actions: [
          IconButton(tooltip: 'جستجو', icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.pushNamed(context, '/search')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(isPkg ? Icons.local_fire_department_rounded : Icons.water_drop_rounded, color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPkg
                      ? 'عیب‌یابی پکیج: برند و مدل را انتخاب کنید، کد خطا را پیدا کنید یا از روی علامت، مشکل را تشخیص دهید.'
                      : 'عیب‌یابی دستگاه تصفیه آب: برند و مدل را انتخاب کنید یا از روی علامت، علت مشکل را پیدا کنید.',
                  style: const TextStyle(fontSize: 12.5, height: 1.7),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MenuTile(
                icon: e.$1, color: e.$2, title: e.$3, subtitle: e.$4,
                onTap: () => Navigator.pushNamed(context, e.$5, arguments: e.$6),
              ),
            ),
        ],
      ),
    );
  }
}

/// لیست برندها با جستجوی محلی
class BrandsScreen extends StatefulWidget {
  final String cat;
  const BrandsScreen({super.key, required this.cat});
  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  String _q = '';
  late final Future<List<Brand>> _future = CatalogRepository.instance.brands(widget.cat);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cat == 'pkg' ? 'برندهای پکیج' : 'برندهای تصفیه آب')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'جستجوی برند...',
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Brand>>(
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
                  : all.where((b) => b.name.contains(_q) || b.en.toLowerCase().contains(_q.toLowerCase())).toList();
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.factory_outlined, title: 'نتیجه‌ای پیدا نشد.', message: 'برند دیگری را جستجو کنید.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final b = list[i];
                  return TyListItem(
                    leading: CircleAvatar(
                      backgroundColor: TyColors.navy.withValues(alpha: 0.08),
                      child: Text(b.name.isNotEmpty ? b.name.substring(0, 1) : '؟',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: TyColors.navy)),
                    ),
                    title: b.name,
                    subtitle: '${b.en.isNotEmpty ? '${b.en} • ' : ''}${b.deviceCount} مدل',
                    trailing: b.sample ? const _SampleBadge() : null,
                    onTap: () => Navigator.pushNamed(context, '/devices', arguments: b.id),
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

class _SampleBadge extends StatelessWidget {
  const _SampleBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TyColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('نمونه اولیه', style: TextStyle(fontSize: 10, color: TyColors.warning, fontWeight: FontWeight.w700)),
    );
  }
}

/// مدل‌های یک برند
class DevicesScreen extends StatelessWidget {
  final String brandId;
  const DevicesScreen({super.key, required this.brandId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Brand?>(
      future: CatalogRepository.instance.brand(brandId),
      builder: (context, bsnap) {
        final b = bsnap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(b?.name ?? 'مدل‌ها'),
            actions: [
              if (b != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FavButton(type: 'brand', id: b.id, title: b.name, sub: b.en),
                ),
              if (b != null && b.sample) const Center(child: _SampleBadge()),
              const SizedBox(width: 8),
            ],
          ),
          body: FutureBuilder<List<Device>>(
            future: CatalogRepository.instance.devicesOf(brandId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const EmptyState(icon: Icons.error_outline, title: 'خطای داخلی', message: 'در خواندن داده‌ها مشکلی پیش آمد.');
              }
              final list = snap.data ?? const [];
              if (list.isEmpty) {
                return const EmptyState(icon: Icons.devices_other_rounded, title: 'لیست خالی', message: 'هنوز مدلی برای این برند ثبت نشده است.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final d = list[i];
                  return TyListItem(
                    leading: CircleAvatar(
                      backgroundColor: TyColors.teal.withValues(alpha: 0.12),
                      child: Icon(d.cat == 'pkg' ? Icons.local_fire_department_rounded : Icons.water_drop_rounded,
                          color: TyColors.teal, size: 20),
                    ),
                    title: d.model,
                    subtitle: '${d.type}${d.cap.isNotEmpty ? ' • ${d.cap}' : ''}',
                    trailing: d.sample ? const _SampleBadge() : null,
                    onTap: () => Navigator.pushNamed(context, '/device', arguments: d.id),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// صفحه اطلاعات دستگاه
class DeviceScreen extends StatelessWidget {
  final String deviceId;
  const DeviceScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Device?>(
      future: CatalogRepository.instance.device(deviceId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data;
        if (d == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('دستگاه')),
            body: const EmptyState(icon: Icons.error_outline, title: 'اطلاعات ناقص', message: 'دستگاه موردنظر یافت نشد.'),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(d.displayName)),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: TyColors.teal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(d.cat == 'pkg' ? Icons.local_fire_department_rounded : Icons.water_drop_rounded,
                            color: TyColors.teal, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.brandName ?? '', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                          Text(d.model, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        ]),
                      ),
                      if (d.sample) const _SampleBadge(),
                    ]),
                    const SizedBox(height: 14),
                    _infoRow(context, 'نوع دستگاه', d.type),
                    if (d.cap.isNotEmpty) _infoRow(context, 'ظرفیت', d.cap),
                    if (d.desc.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text(d.desc, style: const TextStyle(fontSize: 13, height: 1.8)),
                    ],
                  ]),
                ),
              ),
              const SectionHeader('اطلاعات دستگاه', icon: Icons.info_outline_rounded),
              MenuTile(
                icon: Icons.error_outline_rounded, color: TyColors.danger,
                title: 'کدهای خطای این دستگاه', subtitle: 'مرتبط با برند ${d.brandName ?? ''}',
                onTap: () => Navigator.pushNamed(context, '/errors', arguments: d.brand),
              ),
              const SizedBox(height: 10),
              MenuTile(
                icon: Icons.build_circle_outlined, color: TyColors.blue,
                title: 'مشکلات رایج', subtitle: 'عیب‌یابی علامت‌محور',
                onTap: () => Navigator.pushNamed(context, '/problems', arguments: d.cat),
              ),
              const SizedBox(height: 10),
              MenuTile(
                icon: Icons.precision_manufacturing_outlined, color: TyColors.teal,
                title: 'قطعات این دسته', subtitle: 'شناخت و بررسی قطعات',
                onTap: () => Navigator.pushNamed(context, '/components', arguments: d.cat),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(BuildContext context, String k, String v) {
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text('$k: ', style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
        Expanded(child: Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
