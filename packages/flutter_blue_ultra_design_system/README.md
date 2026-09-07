# flutter_blue_ultra_design_system

Shared design system for the `flutter_blue_ultra` and
`flutter_blue_ultra_accessory_setup` example applications.

Not published to pub.dev — it exists so both examples render the same UI from one
source instead of keeping duplicate copies of the theme and widgets.

## Layers

| Layer | Location | Purpose |
| --- | --- | --- |
| Tokens | `lib/src/tokens/` | Raw palette, spacing, radii, sizes, motion, type scale |
| Theme | `lib/src/theme/` | `DsColors`, `DsTypography`, `DsDimensions` theme extensions and `DsTheme` |
| Components | `lib/src/components/` | Material-backed widgets built on those tokens |

## Usage

```dart
MaterialApp(
  theme: DsTheme.light(),
  darkTheme: DsTheme.dark(),
  home: const HomeScreen(),
);
```

Inside a widget:

```dart
final colors = DsColors.of(context);
final text = DsTypography.of(context);
final dimens = DsDimensions.of(context);
```

## Customising

Three levels, cheapest first.

**1. Per instance.** Every component takes the standard Material style object for
the widget it wraps, plus explicit overrides where it paints its own content.

```dart
DsButton(
  label: 'Connect',
  variant: DsButtonVariant.outlined,
  size: DsButtonSize.small,
  style: OutlinedButton.styleFrom(foregroundColor: Colors.amber),
  onPressed: _connect,
);
```

**2. Per app, through Material.** Components resolve their defaults from the
normal Material theme, so `FilledButtonTheme`, `ChipTheme`, `ListTileTheme`,
`AppBarTheme` and friends all apply.

```dart
DsTheme.dark().copyWith(
  chipTheme: DsTheme.dark().chipTheme.copyWith(
    shape: const StadiumBorder(side: BorderSide(width: 2)),
  ),
);
```

**3. Per app, through tokens.** Override the theme extensions to restyle every
component at once.

```dart
DsTheme.dark(
  colors: DsColors.dark.copyWith(accent: const Color(0xFF00E5FF)),
  dimensions: DsDimensions.standard.copyWith(radiusLarge: 4),
);
```
