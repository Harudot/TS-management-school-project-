# Smart Campus Navigation — Setup

The Dart code is complete. There are 6 manual steps that need your hands (Firebase project, OAuth, deploy). Do them in order.

## 1. Install Flutter packages

```powershell
cd C:\projects\flutter\ts_management
flutter pub get
```

## 2. Create the Firebase project

1. Go to https://console.firebase.google.com → "Add project". Pick a name (e.g. `smart-campus-app`).
2. Enable: **Authentication** (Email/Password + Google), **Firestore Database** (production mode), **Storage**, **Cloud Messaging**.
3. Add an Android app with package name `com.example.ts_management` (or whatever you set in `android/app/build.gradle`). Download `google-services.json` to `android/app/`.

## 3. Wire Firebase to the Flutter project

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
```

This generates `lib/firebase_options.dart` (already imported by `lib/core/firebase/firebase_init.dart`).

## 4. Google Sign-In (Android only — iOS is out of scope)

1. In the Firebase console → Authentication → Sign-in method → enable **Google**.
2. Add SHA-1 + SHA-256 fingerprints from `cd android && ./gradlew signingReport` to the Android app in Firebase project settings.
3. Re-download `google-services.json`.

## 5. Deploy security rules + Cloud Functions

```powershell
npm install -g firebase-tools
firebase login
cd C:\projects\flutter\ts_management\firebase
firebase init  # select Firestore + Storage + Functions; point to existing project
# Replace the auto-generated firestore.rules / storage.rules with the ones in this folder
cd functions
npm install
cd ..
firebase deploy --only firestore:rules,storage,functions
```

## 6. Seed the dummy building

The seed script is at `scripts/seed_firestore.dart`. The simplest one-shot run:

1. In `lib/main.dart`, after `await initFirebase()`, temporarily add:
   ```dart
   if (const bool.fromEnvironment('SEED', defaultValue: false)) {
     await seedFirestore(); // import 'package:ts_management/../scripts/seed_firestore.dart' relative path
   }
   ```
2. `flutter run --dart-define=SEED=true` once. Verify in Firestore console.
3. Remove the seed call.

(Alternative: paste the body of `seedFirestore()` into a `seed.js` Cloud Function and call it via `firebase functions:shell`.)

## 7. Promote yourself to admin

After signing up via the mobile app:

```powershell
firebase functions:shell
> bootstrapFirstAdmin({}, { auth: { uid: '<your-uid>', token: {} } })
```

Or, equivalently, run in the shell once:

```js
admin.auth().setCustomUserClaims('<your-uid>', { role: 'admin' })
```

Sign out and back in to refresh the token. Then you can open the admin dashboard:

```powershell
flutter run -d chrome -t lib/admin/main_admin.dart
```

## 8. Floor-plan PNGs

The seeded floors have `floorPlanUrl: null`. Upload PNGs (any rectangular building plan) to Firebase Storage and edit the URLs via the admin **Floors** page, OR set them in the Firestore console.

## 9. Run the mobile app

```powershell
flutter run -d <your-android-device>
```

Sign up → tap "Demo: open Main Campus Building" on the Scan tab → tap a room or use Search → pick a start point → follow turn-by-turn → confirm floor transition → Finish.

## Project layout

```
lib/
  main.dart                       mobile app entry
  admin/main_admin.dart           admin web entry (run with -t lib/admin/main_admin.dart)
  admin/pages/                    admin pages
  core/{theme,router,firebase}    M3 theme, go_router, Firebase init
  data/models                     Building, Room, Person, Event, Waypoint, etc.
  data/repositories               Firestore repositories
  domain/services                 RoutingService (Dijkstra), NotificationsService
  features/auth                   login / signup / forgot
  features/dashboard              Home + bottom nav shell
  features/scan                   QR scanner
  features/search                 Rooms / People / Events tabs
  features/building               Building info page
  features/navigation             Map list, indoor turn-by-turn navigation, start-point picker
  features/settings               Settings, Profile
scripts/seed_firestore.dart       Dummy building, floors, rooms, people, events, graph
firebase/firestore.rules          Auth + admin gating
firebase/storage.rules            Auth + admin gating
firebase/functions/index.js       FCM-on-event-create, QR PNG generator, setAdminClaim, bootstrap
```

## What doesn't work yet (post-MVP)

- Photo upload widgets in admin (paths exist in models, you have to type URLs for now).
- Person profile detail page (search returns navigate-to-office; tap shows nothing extra).
- Notification feed UI on Home (you'll see system notifications, but no in-app history list).
- iOS support.
