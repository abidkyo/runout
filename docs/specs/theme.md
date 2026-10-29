# Theme — typography and colors

Owns: the Inter font, `AppTextTheme` styles, and the `ThemeExtension`
shortcuts. Typography and semantic colors are separate; use `context.colors`
at call sites.

## Font

- `assets/fonts/Inter-VariableFont_opsz,wght.ttf`, registered as family
  `Inter` in `pubspec.yaml`.
- Inter is the app-wide default font (`ThemeData.fontFamily`), so every
  `context.textTheme` style is Inter without a per-widget `fontFamily`.
- Weight uses `FontWeight`; no `fontVariations` are set.

## AppTextTheme

`AppTextTheme` is an extension on `TextTheme` in
`lib/core/theme/app_text_theme.dart`. It uses the localized theme text styles,
so sizes and heights come from Material.

```dart
Text(
  'Filler',
  style: context.textTheme.playerName,
)

Text(
  'Germany',
  style: context.textTheme.playerClub.copyWith(
    color: context.colors.onSurfaceVariant,
  ),
)
```

Import `app_text_theme.dart` wherever the getters are used — extensions do
not resolve transitively.

| Token | Base | Used for |
| --- | --- | --- |
| `titleLargeSolid` | titleLarge w500 | generic large title |
| `screenTitle` | titleLarge w500 | home/setup/match AppBars |
| `modeTitle` | titleLarge w500 | mode card label |
| `dialogTitle` | titleLarge w500 | confirm, remaining, new-rack, player picker |
| `dialogBody` | bodyLarge | confirm message |
| `playerName` | titleLarge w500 | match and setup player name |
| `playerClub` | titleMedium | match and setup club |
| `prompt` | titleLarge w500 | "Who breaks?", "Pick player" |
| `fieldText` | titleMedium | picker search/row text |
| `fieldLabel` | labelMedium | picker label/country code |
| `fieldValue` | labelLarge | dropdown value |
| `sectionLabel` | labelLarge | player-panel side label |
| `ballLabel` | labelLarge + tabular figures | ball button |
| `remainingLabel` | titleLarge w500 + tabular figures | remaining-count button |
| `score` | titleMedium + tabular figures, 288 | match score |
| `stepperValue` | titleMedium + tabular figures | number stepper value |
| `timer` | bodyLarge + tabular figures | match timer |
| `stats` | bodyMedium + tabular figures | straight-pool stats |

`AppTextTheme.scoreMaxFontSize` (288) and `scoreMinFontSize` (24) bound the
auto-sized score.

## ThemeExtension

`lib/core/theme/theme_extension.dart`:

- `context.textTheme` — `Theme.of(context).textTheme`, localized, with the
  `AppTextTheme` getters available when that file is imported.
- `context.colors` — shortcut for `Theme.of(context).colorScheme`.

Dynamic layout sizes still use `copyWith(fontSize: ...)` at the call site:
match player name/club, straight-pool stats, and ball-button labels.
