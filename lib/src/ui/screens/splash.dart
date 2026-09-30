import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [TyColors.navy, Color(0xFF0A1F36)],
          ),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0)
                  .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
              child: Hero(
                tag: 'ty-logo',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/images/logo.png', width: 108, height: 108),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('تأسیسات‌یار',
                style: TextStyle(fontFamily: TyTheme.fontFamily, fontSize: 30,
                    fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text('آرشیو تخصصی تعمیرات تأسیسات',
                style: TextStyle(fontFamily: TyTheme.fontFamily, fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.75))),
            const SizedBox(height: 40),
            SizedBox(
              width: 26, height: 26,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ]),
        ),
      ),
    );
  }
}
