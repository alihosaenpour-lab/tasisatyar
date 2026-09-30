import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

/// عنوان بخش با خط تأکید
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const SectionHeader(this.title, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(color: TyColors.teal, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        if (icon != null) ...[Icon(icon, size: 19, color: TyColors.teal), const SizedBox(width: 6)],
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// نشان سطح بررسی: 🟢 ساده / 🟡 فنی / 🔴 تخصصی
class LevelChip extends StatelessWidget {
  final String level;
  final bool compact;
  const LevelChip(this.level, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = levelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(levelLabel(level),
            style: TextStyle(fontSize: compact ? 10.5 : 11.5, color: c, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// حالت خالی یکپارچه
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  const EmptyState({super.key, required this.icon, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ]),
      ),
    );
  }
}

/// آیتم منو با آیکون در قاب رنگی
class MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const MenuTile({super.key, required this.icon, required this.color, required this.title,
      this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55))),
                  ),
              ]),
            ),
            Icon(Icons.chevron_left_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
          ]),
        ),
      ),
    );
  }
}

/// کارت نتایج/لیست‌ها با عنوان و زیرنویس
class TyListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;
  const TyListItem({super.key, required this.title, this.subtitle, this.leading, this.trailing,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(subtitle!,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55), height: 1.5)),
                  ),
              ]),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
      ),
    );
  }
}

/// دکمه ستاره علاقه‌مندی
class FavButton extends StatelessWidget {
  final String type, id, title, sub;
  const FavButton({super.key, required this.type, required this.id, required this.title, this.sub = ''});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final fav = state.isFav(type, id);
    return IconButton(
      tooltip: fav ? 'حذف از ذخیره‌شده‌ها' : 'ذخیره',
      icon: Icon(fav ? Icons.star_rounded : Icons.star_outline_rounded,
          color: fav ? TyColors.warning : null),
      onPressed: () async {
        await state.toggleFavorite(type, id, title, sub);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(fav ? 'از ذخیره‌شده‌ها حذف شد' : 'به ذخیره‌شده‌ها اضافه شد'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
    );
  }
}

/// کارت هشدار ایمنی
class SafetyCard extends StatelessWidget {
  final String? text;
  const SafetyCard({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TyColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TyColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.health_and_safety_outlined, color: TyColors.danger, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text ?? 'برخی عملیات تعمیراتی نیازمند دانش فنی هستند. در صورت نداشتن تخصص، تعمیر را به تکنسین مجاز بسپارید. کار با گاز و برق بدون آموزش خطرناک است.',
            style: const TextStyle(fontSize: 12.5, height: 1.7),
          ),
        ),
      ]),
    );
  }
}

/// چیپ لینک به قطعه/مورد مرتبط
class TyChipLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TyChipLink(this.label, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
      onPressed: onTap,
    );
  }
}
