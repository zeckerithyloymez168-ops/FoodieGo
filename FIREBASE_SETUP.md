# FoodieGo · Firebase Firestore setup

This app connects to a **named Firestore database** called **`FoodieGo`**.

## 1. Create Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. **Add project** (or open an existing one)
3. Enable **Google Analytics** optional

## 2. Create the FoodieGo database

1. Console → **Build** → **Firestore Database**
2. **Create database**
3. Choose **Start in test mode** (or use rules in `firestore.rules` later)
4. Pick a location (e.g. `asia-southeast1`)
5. If asked for **database ID**, enter: **`FoodieGo`**
   - If you only have the default `(default)` database, create a **second** database named `FoodieGo`
   - Multi-database: Firebase Console → Firestore → **Databases** → **Add database** → ID = `FoodieGo`

> The Flutter code uses:
> `FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'FoodieGo')`

## 3. Enable Authentication (email/password)

1. **Build** → **Authentication** → **Get started**
2. Sign-in method → **Email/Password** → Enable

## 4. Link Flutter app (`flutterfire configure`)

In a terminal:

```bash
cd food_order_app

# Login (once)
firebase login

# Generate real firebase_options.dart + platform config
dart pub global activate flutterfire_cli
flutterfire configure
```

- Select your Firebase project  
- Enable platforms you need (Android / iOS / Web / Windows)  
- This **overwrites** `lib/firebase_options.dart` with real API keys  

Optional: after configure, open `lib/firebase_options.dart` and set:

```dart
static const bool isConfigured = true;
```

## 5. Android notes

After `flutterfire configure`, you should have:

- `android/app/google-services.json`

If Google Services plugin is missing, FlutterFire CLI usually adds it.  
`minSdk` should be **21+** (Flutter defaults are fine for recent SDKs).

## 6. Seed menu data into FoodieGo

1. Run the app with Firebase configured  
2. Sign in (register a user with Email/Password)  
3. Open **Profile**  
4. Tap **Seed menu to FoodieGo**  

This writes sample documents into:

```text
FoodieGo
  └── foods/{id}
  └── categories/{id}
```

## 7. Collections used by the app

| Collection | Purpose |
|------------|---------|
| `foods` | Menu items (name, price, imageUrl, …) |
| `categories` | Category chips |
| `orders` | Placed orders + status |
| `users/{uid}` | Profile |
| `users/{uid}/addresses` | Saved addresses |
| `users/{uid}/favorites` | Favorite dishes |
| `users/{uid}/notifications` | User notifications |

### Example `foods` document

Document ID: `pepperoni`

```json
{
  "name": "Pepperoni",
  "description": "Spicy pepperoni pizza",
  "price": 14.5,
  "imageUrl": "https://…",
  "category": "Pizza",
  "rating": 4.9,
  "time": "20 min",
  "kcal": "780 Kcal",
  "ingredients": ["Pepperoni", "Mozzarella"],
  "isPopular": true,
  "isVeg": false,
  "reviewCount": 842
}
```

## 8. Deploy security rules (recommended)

```bash
# Install Firebase CLI if needed
npm install -g firebase-tools

firebase use YOUR_PROJECT_ID
firebase deploy --only firestore:rules
```

For a **named** database you may need to select `FoodieGo` in the Console rules editor, or use the multi-db deploy options available in newer Firebase CLI versions.

## 9. Offline / no Firebase

If `firebase_options.dart` still has `YOUR_PROJECT_ID` placeholders:

- App **still runs**
- Uses local `SampleData`
- Profile shows **Firestore: offline**

## 10. Verify connection

1. Run app → splash should say **Connected to FoodieGo cloud** when ready  
2. Profile → green **Firestore: FoodieGo connected**  
3. Place an order → check Console → Firestore → **FoodieGo** → `orders`  
4. Seed foods → check `foods` collection  

## Troubleshooting

| Issue | Fix |
|--------|-----|
| `permission-denied` | Open rules / use test mode / sign in |
| Empty menu after seed | Pull to refresh / restart app; check database ID is `FoodieGo` not `(default)` |
| Auth fails | Enable Email/Password in Authentication |
| Wrong database | Confirm named DB `FoodieGo` exists and code uses `databaseId: 'FoodieGo'` |
| Windows/Web | Run `flutterfire configure` with those platforms selected |

## Code map

```text
lib/
  firebase_options.dart          # from flutterfire configure
  services/
    firebase_bootstrap.dart      # init
    firestore_service.dart       # FoodieGo instance
    food_repository.dart         # foods CRUD + seed
    order_repository.dart        # orders
    user_repository.dart         # profile / addresses / favorites
  providers/
    catalog_provider.dart        # live menu
    order_provider.dart          # places orders to cloud
    auth_provider.dart           # Firebase Auth + local fallback
```
