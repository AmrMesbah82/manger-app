# Manger Plus

Learning-center system: **admin & teacher console on desktop**, **student & parent app on phone and tablet**, all on Firebase.

Start with **[SETUP.md](SETUP.md)** — Firebase setup, the first admin, the demo-data button, the architecture and the data model.

```bash
flutter pub get
flutterfire configure --out=lib/firebase/prod/firebase_options.dart
firebase deploy --only firestore:rules,firestore:indexes,storage
flutter run -d macos
```
