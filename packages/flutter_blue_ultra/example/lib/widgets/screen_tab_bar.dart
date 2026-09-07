import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class ScreenTabBar extends StatelessWidget {
  const ScreenTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (index, tab) in tabs.indexed)
          Expanded(
            child: _Tab(
              label: tab,
              selected: index == currentIndex,
              onTap: () => onSelected(index),
            ),
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: DsSpace.s12,
              bottom: DsSpace.s12,
            ),
            child: Text(
              label,
              style: selected
                  ? DsTextStyles.bodySmBold(color: colors.textPrimary)
                  : DsTextStyles.bodySm(color: colors.textFaint),
            ),
          ),
          Container(
            height: 2,
            color: selected ? colors.accent : colors.border,
          ),
        ],
      ),
    );
  }
}
