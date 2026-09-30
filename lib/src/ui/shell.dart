import 'package:flutter/material.dart';

/// اسکلت صفحات اصلی با Bottom Navigation حرفه‌ای
class TyTabScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final int tab; // -1 یعنی بدون تب فعال
  const TyTabScaffold({super.key, required this.body, this.appBar, this.tab = -1});

  static const _routes = ['/home', '/search', '/pkg', '/ro', '/more'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: tab < 0
          ? null
          : NavigationBar(
              selectedIndex: tab,
              height: 66,
              onDestinationSelected: (i) {
                if (i == tab) return;
                Navigator.pushNamedAndRemoveUntil(context, _routes[i], (r) => false);
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'خانه'),
                NavigationDestination(icon: Icon(Icons.search_rounded), label: 'جستجو'),
                NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department_rounded), label: 'پکیج'),
                NavigationDestination(icon: Icon(Icons.water_drop_outlined), selectedIcon: Icon(Icons.water_drop_rounded), label: 'تصفیه آب'),
                NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'بیشتر'),
              ],
            ),
    );
  }
}
