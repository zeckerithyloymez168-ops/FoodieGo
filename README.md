# GreenBite — Flutter Food Delivery App

Emerald-green food delivery UI in **Flutter** (not the HTML web mockup).

## Screens

| Tab | Screen |
|-----|--------|
| **Home** | Soft green gradient, location, search, Food/Grocery/Medicine pills, categories, kebab promo banner, popular horizontal rail |
| **Menu** | Pepperoni hero, 2-column pizza grid (Pepperoni, Margherita, BBQ Chicken, …) |
| **Orders** | Order history after checkout |
| **Cart** | Line items, totals, checkout |

Bottom bar uses **frosted glass** (`BackdropFilter` blur).

## Run in VS Code

1. Open folder: `food_order_app`
2. Install **Flutter** + **Dart** extensions
3. Pick a device → press **F5**, or:

```bash
cd food_order_app
flutter pub get
flutter run
```

## Project layout

```text
lib/
  main.dart
  theme/app_theme.dart       # emerald palette
  data/sample_data.dart      # popular items + pizzas
  models/
  providers/                 # cart + orders
  screens/                   # home, pizza menu, cart, …
  widgets/                   # glass nav, food cards, images
```

Internet required for Unsplash food images.
