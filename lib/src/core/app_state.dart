import 'package:flutter/material.dart';
import '../data/repository.dart';

/// وضعیت سراسری اپ: تم، علاقه‌مندی‌ها و تاریخچه (همه محلی و آفلاین).
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  ThemeMode themeMode = ThemeMode.light;
  Set<String> _favs = {};
  int historyVersion = 0;

  Future<void> init() async {
    _favs = await CatalogRepository.instance.favoriteKeys();
  }

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    notifyListeners();
  }

  bool isFav(String type, String id) => _favs.contains('$type:$id');

  Future<void> toggleFavorite(String type, String id, String title, String sub) async {
    final nowFav = !isFav(type, id);
    await CatalogRepository.instance.setFavorite(type, id, title, sub, nowFav);
    _favs = await CatalogRepository.instance.favoriteKeys();
    notifyListeners();
  }

  Future<void> logHistory(String type, String id, String title, String sub) async {
    await CatalogRepository.instance.logHistory(type, id, title, sub);
    historyVersion++;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await CatalogRepository.instance.clearHistory();
    historyVersion++;
    notifyListeners();
  }
}

/// دسترسی راحت به AppState در درخت ویجت‌ها
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope یافت نشد');
    return scope!.notifier!;
  }
}
