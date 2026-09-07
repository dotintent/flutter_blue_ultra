import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class ReadonlyValueField extends StatelessWidget {
  const ReadonlyValueField({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpace.s16,
        vertical: DsSpace.s12,
      ),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(DsRadius.medium),
      ),
      child: SelectableText(
        value,
        style: DsTextStyles.monoLg(color: colors.textPrimary),
      ),
    );
  }
}

class PayloadField extends StatelessWidget {
  const PayloadField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.footerLeft,
    this.footerRight,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? footerLeft;
  final String? footerRight;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final footerLeft = this.footerLeft;
    final footerRight = this.footerRight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DsTextStyles.monoLabel(color: colors.textFaint),
        ),
        const SizedBox(height: DsSpace.s8),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(DsRadius.medium),
            border: Border.all(color: colors.borderHi),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
            ],
            textCapitalization: TextCapitalization.characters,
            cursorColor: colors.accent,
            style: DsTextStyles.monoLg(color: colors.textPrimary),
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DsSpace.s16,
                vertical: DsSpace.s12,
              ),
              hintText: hint,
              hintStyle: DsTextStyles.monoLg(color: colors.textFaint),
            ),
          ),
        ),
        if (footerLeft != null || footerRight != null) ...[
          const SizedBox(height: DsSpace.s8),
          Row(
            children: [
              if (footerLeft != null)
                Text(
                  footerLeft,
                  style: DsTextStyles.monoCaption(color: colors.textFaint),
                ),
              const Spacer(),
              if (footerRight != null)
                Text(
                  footerRight,
                  style: DsTextStyles.monoCaption(color: colors.textFaint),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class QuickFillChip extends StatelessWidget {
  const QuickFillChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DsSpace.s8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceControl,
          borderRadius: BorderRadius.circular(DsRadius.small),
        ),
        child: Text(
          label,
          style: DsTextStyles.monoMd(color: colors.textPrimary),
        ),
      ),
    );
  }
}
