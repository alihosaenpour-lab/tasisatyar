import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/core/app_state.dart';
import 'src/core/theme.dart';
import 'src/data/database.dart';
import 'src/ui/screens/splash.dart';
import 'src/ui/screens/home.dart';
import 'src/ui/screens/search.dart';
import 'src/ui/screens/catalog.dart';
import 'src/ui/screens/lists.dart';
import 'src/ui/screens/details.dart';
import 'src/ui/screens/user.dart';
import 'src/ui/screens/misc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  await AppState.instance.init();
  runApp(const TyApp());
}

class TyApp extends StatelessWidget {
  const TyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: AppState.instance,
      child: AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) => MaterialApp(
          title: 'تأسیسات‌یار',
          debugShowCheckedModeBanner: false,
          theme: TyTheme.light(),
          darkTheme: TyTheme.dark(),
          themeMode: AppState.instance.themeMode,
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          initialRoute: '/splash',
          onGenerateRoute: (settings) {
            final name = settings.name ?? '/home';
            final args = settings.arguments;
            Widget page;
            switch (name) {
              case '/splash': page = const SplashScreen(); break;
              case '/home': page = const HomeScreen(); break;
              case '/search': page = const SearchScreen(); break;
              case '/pkg': page = const CategoryScreen(cat: 'pkg'); break;
              case '/ro': page = const CategoryScreen(cat: 'ro'); break;
              case '/more': page = const MoreScreen(); break;
              case '/brands': page = BrandsScreen(cat: args as String); break;
              case '/devices': page = DevicesScreen(brandId: args as String); break;
              case '/device': page = DeviceScreen(deviceId: args as String); break;
              case '/errors':
                page = ErrorListScreen(brandId: args is String ? args : null); break;
              case '/error': page = ErrorDetailScreen(errorId: args as String); break;
              case '/problems': page = ProblemListScreen(cat: args as String); break;
              case '/problem': page = ProblemDetailScreen(problemId: args as String); break;
              case '/components':
                page = ComponentListScreen(cat: args is String ? args : null); break;
              case '/component': page = ComponentDetailScreen(componentId: args as String); break;
              case '/favorites': page = const FavoritesScreen(); break;
              case '/history': page = const HistoryScreen(); break;
              case '/about': page = const AboutScreen(); break;
              case '/settings': page = const SettingsScreen(); break;
              case '/guide': page = GuideScreen(cat: args as String); break;
              default: page = const HomeScreen();
            }
            return MaterialPageRoute(builder: (_) => page, settings: settings);
          },
        ),
      ),
    );
  }
}
