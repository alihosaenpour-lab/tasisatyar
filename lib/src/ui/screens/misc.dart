import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../data/repository.dart';
import '../shell.dart';
import '../widgets.dart';

/// تب «بیشتر»
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, Color, String, String?, String)>[
      (Icons.star_outline_rounded, TyColors.warning, 'ذخیره‌شده‌ها', 'خطاها، مشکلات و قطعات نشان‌شده', '/favorites'),
      (Icons.history_rounded, TyColors.blue, 'تاریخچه', 'آخرین موارد مشاهده‌شده', '/history'),
      (Icons.precision_manufacturing_outlined, TyColors.teal, 'قطعات', 'بانک قطعات پکیج و تصفیه آب', '/components'),
      (Icons.info_outline_rounded, TyColors.navy, 'درباره تأسیسات‌یار', 'نسخه، حریم خصوصی و تماس', '/about'),
      (Icons.settings_outlined, const Color(0xFF5C6B79), 'تنظیمات', 'حالت تاریک و مدیریت داده‌ها', '/settings'),
    ];
    return TyTabScaffold(
      tab: 4,
      appBar: AppBar(title: const Text('بیشتر')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MenuTile(
                icon: it.$1, color: it.$2, title: it.$3, subtitle: it.$4,
                onTap: () => Navigator.pushNamed(context, it.$5),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/logo.png', width: 40, height: 40),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('تأسیسات‌یار — نسخه ۱٫۰٫۰\nکاملاً آفلاین • بدون نیاز به اینترنت',
                      style: TextStyle(fontSize: 12, height: 1.7)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// درباره ما
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('درباره تأسیسات‌یار')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(children: [
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/images/logo.png', width: 88, height: 88),
              ),
              const SizedBox(height: 14),
              Text('تأسیسات‌یار',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text('آرشیو تخصصی تعمیرات تأسیسات',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            ]),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'تأسیسات‌یار یک آرشیو تخصصی برای دسترسی سریع به اطلاعات عیب‌یابی، خطاها، قطعات و مشکلات تجهیزات تأسیسات است. هدف این نسخه، کمک به تعمیرکاران و کاربران برای تشخیص سریع مشکلات پکیج و دستگاه‌های تصفیه آب است — کاملاً آفلاین و بدون نیاز به اینترنت.',
                style: TextStyle(fontSize: 13, height: 1.9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<Map<String, String>>(
            future: () async {
              final v = await CatalogRepository.instance.meta('seed_version', fallback: '۱٫۰٫۰');
              final u = await CatalogRepository.instance.meta('db_version_label', fallback: '—');
              return {'v': v, 'u': u};
            }(),
            builder: (context, snap) {
              final m = snap.data ?? const {'v': '۱٫۰٫۰', 'u': '—'};
              return Card(
                child: Column(children: [
                  ListTile(dense: true, leading: const Icon(Icons.phone_android_rounded),
                      title: const Text('نسخه برنامه'), trailing: const Text('۱٫۰٫۰')),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(dense: true, leading: const Icon(Icons.dns_outlined),
                      title: const Text('نسخه بانک اطلاعاتی'), trailing: Text('${m['v']} • ${m['u']}')),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(dense: true, leading: const Icon(Icons.shield_outlined),
                      title: const Text('حریم خصوصی'),
                      subtitle: const Text('همه داده‌ها فقط روی دستگاه شما ذخیره می‌شوند؛ هیچ اطلاعاتی ارسال نمی‌شود.', style: TextStyle(fontSize: 11.5, height: 1.6))),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(dense: true, leading: const Icon(Icons.mail_outline_rounded),
                      title: const Text('تماس با ما'),
                      subtitle: const Text('support@tasisatyar.app', style: TextStyle(fontSize: 12))),
                ]),
              );
            },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TyColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TyColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'توجه: بخشی از اطلاعات این نسخه «داده اولیه MVP» است و موارد مدل‌محور با برچسب «نمونه اولیه» مشخص شده‌اند. همواره دستورالعمل سازنده دستگاه را ملاک نهایی قرار دهید.',
              style: TextStyle(fontSize: 11.5, height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// تنظیمات
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            const SectionHeader('ظاهر', icon: Icons.palette_outlined),
            Card(
              child: Column(children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light, groupValue: state.themeMode,
                  title: const Text('روشن'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  onChanged: (m) => state.setThemeMode(m!),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark, groupValue: state.themeMode,
                  title: const Text('تاریک'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  onChanged: (m) => state.setThemeMode(m!),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system, groupValue: state.themeMode,
                  title: const Text('هماهنگ با سیستم'),
                  secondary: const Icon(Icons.settings_suggest_outlined),
                  onChanged: (m) => state.setThemeMode(m!),
                ),
              ]),
            ),
            const SectionHeader('داده‌ها', icon: Icons.storage_outlined),
            Card(
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.history_rounded, color: TyColors.blue),
                  title: const Text('پاک‌کردن تاریخچه مشاهده'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () async {
                    await state.clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تاریخچه پاک شد.'), behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1)));
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.wifi_off_rounded, color: TyColors.teal),
                  title: Text('حالت آفلاین'),
                  subtitle: Text('همه امکانات اصلی بدون اینترنت فعال هستند.', style: TextStyle(fontSize: 11.5)),
                ),
              ]),
            ),
            const SectionHeader('اطلاعات', icon: Icons.info_outline_rounded),
            MenuTile(
              icon: Icons.info_outline_rounded, color: TyColors.navy,
              title: 'درباره تأسیسات‌یار', subtitle: 'نسخه، حریم خصوصی، تماس',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }
}

/// راهنمای گام‌به‌گام عیب‌یابی
class GuideScreen extends StatelessWidget {
  final String cat;
  const GuideScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final isPkg = cat == 'pkg';
    final steps = <(IconData, String, String)>[
      (Icons.warning_amber_rounded, '۱. ایمنی اول',
          isPkg
              ? 'قبل از هر بررسی، از سلامت دودکش، برق و گاز مطمئن شوید. بوی گاز = قطع شیر اصلی و تهویه، بدون روشن‌کردن وسایل برقی.'
              : 'قبل از بازکردن هر قسمت، برق دستگاه را بکشید و شیر آب ورودی را ببندید.'),
      (Icons.document_scanner_outlined, '۲. علامت یا کد خطا را ثبت کنید',
          isPkg
              ? 'اگر روی نمایشگر کدی مانند E01 دیده می‌شود، همان را در بخش «کدهای خطا» جستجو کنید؛ در غیر این صورت از «مشکلات رایج» شروع کنید.'
              : 'علامت مشکل را دقیق تعریف کنید: آب کم؟ نشتی؟ طعم بد؟ سپس از «مشکلات رایج» شروع کنید.'),
      (Icons.manage_search_rounded, '۳. علت‌ها را به ترتیب بررسی کنید',
          'در صفحه هر مشکل، علت‌ها از محتمل‌ترین و ساده‌ترین مورد شروع شده‌اند. ابتدا بررسی‌های 🟢 ساده را انجام دهید.'),
      (Icons.precision_manufacturing_outlined, '۴. قطعات مرتبط را بشناسید',
          'برای هر علت، قطعات مرتبط مشخص شده‌اند؛ در صفحه قطعه، وظیفه، علائم خرابی و روش بررسی آن را ببینید.'),
      (Icons.handyman_outlined, '۵. راهکار را اجرا یا ارجاع دهید',
          'اگر سطح مورد 🔴 تخصصی بود یا پس از بررسی حل نشد، کار را به تکنسین مجاز بسپارید؛ تعمیرات گاز و برد کار هر کسی نیست.'),
      (Icons.star_outline_rounded, 'نکته',
          'موارد پرکاربرد را ⭐ ذخیره کنید تا دفعه بعد بدون جستجو در «ذخیره‌شده‌ها» به آن‌ها برسید.'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(isPkg ? 'راهنمای عیب‌یابی پکیج' : 'راهنمای عیب‌یابی تصفیه آب')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: TyColors.teal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.$1, color: TyColors.teal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(s.$3,
                            style: TextStyle(fontSize: 12.5, height: 1.8,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: 8),
          MenuTile(
            icon: Icons.build_circle_outlined, color: TyColors.blue,
            title: 'شروع عیب‌یابی بر اساس مشکل', subtitle: 'لیست مشکلات رایج',
            onTap: () => Navigator.pushNamed(context, '/problems', arguments: cat),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
