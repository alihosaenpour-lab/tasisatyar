import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../widgets.dart';

const _typeLabels = {
  'error': 'خطاها', 'problem': 'مشکلات', 'component': 'قطعات',
  'device': 'مدل‌ها', 'brand': 'برندها',
};
const _typeIcons = {
  'error': Icons.error_outline_rounded,
  'problem': Icons.build_circle_outlined,
  'component': Icons.precision_manufacturing_outlined,
  'device': Icons.devices_other_rounded,
  'brand': Icons.factory_outlined,
};

void openUserItem(BuildContext context, UserItem it) {
  final route = switch (it.type) {
    'error' => '/error', 'problem' => '/problem', 'component' => '/component',
    'device' => '/device', 'brand' => '/devices', _ => null,
  };
  if (route != null) Navigator.pushNamed(context, route, arguments: it.id);
}

/// ذخیره‌شده‌ها
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ذخیره‌شده‌ها')),
      body: AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) => FutureBuilder<List<UserItem>>(
          future: CatalogRepository.instance.favorites(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data ?? const [];
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.star_outline_rounded,
                title: 'موردی ذخیره نشده است.',
                message: 'با زدن علامت ⭐ در صفحه هر خطا، مشکل یا قطعه، آن را برای دسترسی سریع ذخیره کنید.');
            }
            final grouped = <String, List<UserItem>>{};
            for (final it in list) {(grouped[it.type] ??= []).add(it);}
            return ListView(
              padding: const EdgeInsets.all(14),
              children: [
                for (final type in ['error', 'problem', 'component', 'device', 'brand'])
                  if (grouped[type] != null) ...[
                    SectionHeader(_typeLabels[type]!, icon: _typeIcons[type]),
                    for (final it in grouped[type]!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TyListItem(
                          leading: Icon(_typeIcons[type], color: TyColors.teal),
                          title: it.title,
                          subtitle: it.sub,
                          trailing: IconButton(
                            tooltip: 'حذف از ذخیره‌شده‌ها',
                            icon: const Icon(Icons.star_rounded, color: TyColors.warning),
                            onPressed: () => AppState.instance.toggleFavorite(it.type, it.id, it.title, it.sub),
                          ),
                          onTap: () => openUserItem(context, it),
                        ),
                      ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// آخرین موارد مشاهده‌شده
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('آخرین موارد مشاهده‌شده'),
        actions: [
          IconButton(
            tooltip: 'پاک‌کردن تاریخچه',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: const Text('پاک‌کردن تاریخچه'),
                    content: const Text('همه موارد مشاهده‌شده حذف شوند؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('پاک‌کردن')),
                    ],
                  ),
                ),
              );
              if (ok == true) state.clearHistory();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: state,
        builder: (context, _) => FutureBuilder<List<UserItem>>(
          key: ValueKey(state.historyVersion),
          future: CatalogRepository.instance.history(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data ?? const [];
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'تاریخچه خالی است.',
                message: 'مواردی که مشاهده می‌کنید این‌جا نمایش داده می‌شوند تا سریع به آن‌ها برگردید.');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = list[i];
                return TyListItem(
                  leading: Icon(_typeIcons[it.type] ?? Icons.history_rounded, color: TyColors.blue),
                  title: it.title,
                  subtitle: it.sub,
                  onTap: () => openUserItem(context, it),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
