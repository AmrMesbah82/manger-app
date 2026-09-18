# Manger Plus: setup and architecture

Manger Plus is a learning-center system built on the same architecture as `wash_application`: Clean Architecture per feature, Cubit for screen state, GetX for app-wide settings, and Firebase as the backend.

| Role | Device | What they do |
|---|---|---|
| **Admin** | Desktop only | Creates teachers, students, parents and sections. Switches each teacher's permissions on or off. Sees everything. Has the "Fill demo data" button. |
| **Teacher** | Desktop only | Adds, edits and deletes videos, PDFs, images, exams and quizzes. Assigns them to a section or to single students. Takes attendance, grades results and messages parents, each only if the admin switched it on. |
| **Student** | Phone or tablet only | Home page, library, video / PDF / image viewers, sitting exams and quizzes, and their own grades and attendance. |
| **Parent** | Phone or tablet only | Switches between their children. Sees each child's assignments, grades and attendance, and messages teachers (optionally "about an assignment"). |

"Desktop" means macOS, Windows or Linux. "Phone or tablet" means Android or iOS. On the web, width decides (1100 px and up counts as desktop). Signing in on the wrong kind of device shows a screen explaining where to go instead.

---

## 1. First run

```bash
cd manger_plus
flutter pub get                 # also generates lib/generated/l10n.dart (class S)
```

### Firebase project

1. Create a project at console.firebase.google.com.
2. **Authentication**: Sign-in method → enable **Email/Password**.
3. **Firestore Database**: create it (production mode; the rules below replace the defaults).
4. **Storage**: create the default bucket. New projects need the **Blaze** plan for Cloud Storage. It still has a free quota, but a card is required.
5. Connect the app:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --out=lib/firebase/prod/firebase_options.dart
```

   Use exactly that `--out` path. Until you run this, the app starts and the sign-in screen says "Firebase is not configured yet".

6. Deploy the rules and indexes. Install the Firebase CLI first with `npm i -g firebase-tools`, then:

```bash
firebase login
firebase use --add                     # pick your project
firebase deploy --only firestore:rules,firestore:indexes,storage
```

   The first Storage deploy asks to let Storage rules read Firestore (they check the uploader's role). Answer **yes**.

### Create the admin, then fill demo data

1. `flutter run -d macos` (or windows / linux / chrome).
2. On the sign-in screen click **"First time? Set up the center"**. Enter your name, email and password. That becomes the admin account. It works **once per project**: after that the button disappears and the rules refuse it.
3. In the console, **Overview → Fill demo data**. This writes to Firestore and Auth:

| Account (password `123456`) | Role |
|---|---|
| `sara@demo.mangerplus.app` | Teacher (Math), all permissions |
| `omar@demo.mangerplus.app` | Teacher (Science), no exams, grades or messages |
| `youssef@…`, `laila@…`, `adam@…` | Students, Grade 7 A |
| `nour@…`, `karim@…`, `hana@…` | Students, Grade 8 B |
| `mona@demo.mangerplus.app` | Parent of Youssef **and** Nour |
| `hassan@…`, `adel@…` | Parents |

   The demo lessons point at public sample files. Your real lessons are uploaded from **Content → Add content** into Cloud Storage.

   **Remove demo data** deletes every document marked `demo: true`. The Auth accounts stay, because only the Admin SDK can delete another user; pressing Fill again reuses them.

### Trying the phone apps on your Mac

Run on an Android emulator, an iOS simulator or a device, and sign in as a student or parent. In **debug builds only**, the "wrong device" screen also has **Preview anyway**. It makes this machine pretend to be a phone so you can click through everything on one computer. Undo it in Settings → Developer.

---

## 2. Architecture (same as wash_application)

```
lib/
├── main.dart                     storage → Firebase → controllers → ScreenUtil → Splash
├── firebase/prod/firebase_options.dart   (flutterfire output)
├── l10n/intl_en.arb, intl_ar.arb (every string; English + Arabic)
├── generated/                    (gen-l10n output, class S; do not edit)
├── core/                         copied from wash (theme, custom widgets, helpers)
│   ├── constants/  app_constants, app_keys, app_assets, firebase_collections
│   ├── network/    app_firebase (init, Storage, account factory), app_failure, guard
│   ├── helper/     platform_helper (DeviceKind + role→device rule), firestore_mapper, stream_combine
│   └── custom/     1..104 from wash + 110-app_widgets (AppButton, Surface, TypeBadge, AppAvatar, InfoBanner…)
└── features/
    ├── onboarding/  o1_splash (AppRouter), o2_authentication (users: domain/data, login, session)
    ├── academy/     ac1_core: domain + data for sections, content, submissions, attendance
    ├── console/     c1_shell (rail + role-filtered pages), c2_overview (+ DemoSeeder), c3_settings
    ├── admin/       a1_people (teachers/students/parents + permission switches), a2_sections
    ├── teacher/     t1_content (CRUD + upload + questions + assign), t2_attendance, t3_grades, t4_my_students
    ├── student/     s1_home (LearnerCubit), s2_library, s3_viewer, s4_assessment, s5_results
    ├── parent/      p1_home (child switcher), p2_child (messages)
    ├── messages/    m1_conversations (shared by teacher + parent)
    └── settings/    se1_settings (one SettingsBody for every role)
```

**The patterns carried over from wash:**

- Each feature has `domain/` (entities, enums, base_repository), `data/` (models, remote data sources, repository), and `presentation/` (cubit + state, pages, widgets).
- Repositories return `Either<AppFailure, T>`. An improvement on wash: `AppFailure` is an enum turned into words by `message(context)`, so errors are Arabic in an Arabic build.
- Collection and field names live only in `FirebaseCollections`. Storage keys live only in `AppKeys`. Asset paths live only in `AppAssets`.
- Firestore reads go through the `FirestoreMap` safe accessors.
- One router: `AppRouter` in `splash_screen.dart` decides every landing (role × device).

**New in this app:**

- `SessionController` (GetX, permanent) follows the signed-in user's document live. When the admin flips a teacher's permission switch, the teacher's console adds or removes that page within a second. Switching an account off signs it out.
- The admin creates accounts with a **second Firebase app** (`AppFirebase.createAccount`), so the admin stays signed in. No Cloud Functions are needed for this.
- Teacher permissions are checked twice: in the UI (`AppUser.can`) and in `firestore.rules` (`can()`).

## 3. Data model

| Collection | Key fields | Who writes |
|---|---|---|
| `users/{uid}` | `role`, `active`, `permissions.{video,pdf,image,exam,quiz,attendance,grades,messages}`, `section_ids` (teacher), `section_id` + `parent_ids` (student), `children_ids` (parent) | Admin (plus the first-admin setup batch) |
| `sections/{id}` | `name`, `level` | Admin |
| `content/{id}` | `type`, `title`, `teacher_id`, `file_url`, `storage_path`, `questions[]`, `section_ids[]`, `student_ids[]`, `due_at`, `published` | Teacher (own items, allowed types, own sections) and admin |
| `submissions/{contentId_uid}` | `answers[]`, `score`, `total`, `graded_by`, `feedback` | Student (once), teacher with Grades |
| `attendance/{date_uid}` | `student_id`, `section_id`, `date` (yyyy-MM-dd), `status` | Teacher with Attendance |
| `conversations/{teacher_parent_student}` + `messages/` | `participant_ids[2]`, `last_message` | The two participants |
| `config/setup` | `admin_uid` | Created once with the first admin |

## 4. Things to know before going live

- **Exam marking happens on the phone.** The answer key is in the content document, so a determined student could read it. That is fine for quizzes and homework. For exams that matter, move marking into a Cloud Function and store the key in a teacher-only subcollection (the wash `placeOrder` function is the pattern).
- **The admin can read every conversation.** The rules allow it on purpose, so the center stays accountable for what teachers write to parents. Mention it in your privacy notice, or remove `isAdmin() ||` from the conversation rules.
- **Deleting a person deletes their profile, not their Auth account.** They can no longer get in, but the email stays taken until you delete it in Firebase Console → Authentication.
- **Brand colours** set in Settings are saved per computer.
- **macOS** needs network access and a Keychain group to sign in (the same lessons as wash). `macos/Runner/*.entitlements` and the signing team are already set. If signing fails, open `macos/Runner.xcworkspace` in Xcode and pick your team.
- Run `flutter analyze` after `pub get`. The code was written without a Flutter SDK available, so the first analyze is the real compile check. Send me anything it reports and I'll fix it.
