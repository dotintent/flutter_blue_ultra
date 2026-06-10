import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class IntentMark extends StatelessWidget {
  const IntentMark({super.key, this.height = 18});

  final double height;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: height * 0.3,
            height: height * 0.3,
            decoration: const BoxDecoration(
              color: IntentColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'intent',
            style: GoogleFonts.crimsonPro(
              fontSize: height,
              fontWeight: FontWeight.w400,
              color: it.textPrimary,
              letterSpacing: -0.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class IntentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IntentAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.brand = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool brand;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final leading = this.leading;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Container(
      decoration: BoxDecoration(
        color: it.bg,
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      padding: EdgeInsets.fromLTRB(brand ? 20 : 16, 14, 16, brand ? 14 : 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: brand
                  ? const IntentMark(height: 18)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title ?? '',
                          style:
                              IntentTextStyles.serifTitle(17, it.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: IntentTextStyles.mono(10.5, it.textDim),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}

class IntentIconBtn extends StatelessWidget {
  const IntentIconBtn({
    super.key,
    required this.child,
    this.onTap,
    this.accent = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent ? it.accent : Colors.transparent,
          border: accent ? null : Border.all(color: it.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(child: child),
      ),
    );
  }
}

enum ChipKind { defaultKind, notify, muted, accent }

class IntentChip extends StatelessWidget {
  const IntentChip({
    super.key,
    required this.label,
    this.kind = ChipKind.defaultKind,
    this.small = true,
  });

  final String label;
  final ChipKind kind;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    Color bg;
    Color fg;
    switch (kind) {
      case ChipKind.notify:
        bg = it.accentSoft;
        fg = it.accent;
      case ChipKind.muted:
        bg = it.surfaceAlt;
        fg = it.textDim;
      case ChipKind.accent:
        bg = it.accent;
        fg = Colors.white;
      default:
        bg = it.chipBg;
        fg = it.textPrimary;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: kind != ChipKind.accent ? Border.all(color: it.border) : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: IntentTextStyles.mono(small ? 10 : 11, fg, letterSpacing: 0.4),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    this.count,
    this.trailing,
  });

  final String label;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: IntentTextStyles.monoLabel(10, it.textFaint),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text('· $count', style: IntentTextStyles.mono(10, it.accent)),
          ],
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: it.border)),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
