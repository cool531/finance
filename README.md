# Luxury Finance

A Thai-language personal expense tracker for Android. Log a spend in about five
seconds, then see where the month actually went: daily chart, category
breakdown, a necessary-vs-wanted split, savings goals, and a 0–100 financial
health score.

Everything is stored on the device with `shared_preferences`. There is no
account, no network code, and no analytics.

![Feature graphic](store/feature_graphic_1024x500.png)

## Running it

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

## How the code is laid out

| File | What lives there |
| --- | --- |
| `main.dart` | App root and the gate that picks splash / onboarding / dashboard |
| `finance_provider.dart` | All state and persistence, plus every derived figure the screens show |
| `Model.dart` | `Expense`, `Goal`, `Recommendation` and their enums |
| `AppColors.dart` / `AppTheme.dart` | Brand palette, and the light + dark themes |
| `common_widgets.dart` | Cards, animated amounts, progress bars, the score ring, chips |
| `HomeScreen.dart` | Dashboard: balance, stats, insight, goal, donut, recent list |
| `Expenselistscreen.dart` | Searchable, filterable, day-grouped expense list |
| `AnalysisScreen.dart` | Score, daily bar chart, category and necessity breakdowns |
| `GoalsScreen.dart` | Savings goals with contributions |
| `AddExpensescreen.dart` | Add and edit an expense |
| `report_screen.dart` | Month in review |
| `settings_screen.dart` | Name, income, savings target, theme, data controls |
| `onboarding_screen.dart` | First-run welcome and setup |

### State

One `FinanceProvider` (`ChangeNotifier`) holds the expenses, goals and
settings, and exposes the derived numbers — monthly totals, category splits,
daily totals, month-over-month deltas, the score, and the rule-based
recommendations. Screens read it with `context.watch`; writes go through its
methods, which persist and then notify.

A fresh install starts **empty**. The sample dataset only loads if someone asks
for it, from the last button in onboarding or from Settings.

### Theming

Screens never hardcode a surface or text colour. Brand and category colours
come from `AppColors`; everything else comes from the active `ColorScheme`
through the `context.cs` / `context.tt` extensions, which is what makes dark
mode work without a second set of widgets.

## Tests

```bash
flutter test
```

- `screens_smoke_test.dart` pumps every screen in both themes on a phone-sized
  surface and fails on any layout error. This is the one that catches "blank
  screen on device" bugs, which the analyzer cannot see.
- `finance_provider_test.dart` covers the first-run contract, onboarding,
  persistence across restarts, and clearing data.
- `widget_test.dart` covers formatting and model round-trips.

## Publishing

See [`store/RELEASE.md`](store/RELEASE.md) for the keystore, signing and
upload steps, [`store/listing.md`](store/listing.md) for the listing copy, and
[`store/PRIVACY.md`](store/PRIVACY.md) for the privacy policy.

The package name is `com.cool531.luxuryfinance`. **It cannot be changed after
the first Play upload** — set it in `android/app/build.gradle.kts` and rename
the folder under `android/app/src/main/kotlin/` before then if you want
something else.
