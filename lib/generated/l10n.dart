import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Manger Plus'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Learning, organised'**
  String get appTagline;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @typeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get typeVideo;

  /// No description provided for @typePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get typePdf;

  /// No description provided for @typeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get typeImage;

  /// No description provided for @typeExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get typeExam;

  /// No description provided for @typeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get typeQuiz;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @permissionPublishDesc.
  ///
  /// In en, this message translates to:
  /// **'Can add, edit and delete {type} content'**
  String permissionPublishDesc(String type);

  /// No description provided for @permissionAttendanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Can take attendance for their sections'**
  String get permissionAttendanceDesc;

  /// No description provided for @permissionGradesDesc.
  ///
  /// In en, this message translates to:
  /// **'Can review and grade student results'**
  String get permissionGradesDesc;

  /// No description provided for @permissionMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Can message parents'**
  String get permissionMessagesDesc;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary colour'**
  String get primaryColor;

  /// No description provided for @secondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary colour'**
  String get secondaryColor;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get colors;

  /// No description provided for @errWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get errWrongCredentials;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a valid email address.'**
  String get errInvalidEmail;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters for the password.'**
  String get errWeakPassword;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errUserDisabled;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get errTooManyRequests;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errNetwork;

  /// No description provided for @errProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'This account has no profile. Ask the admin to create it from the console.'**
  String get errProfileMissing;

  /// No description provided for @errAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'This account is switched off. Contact the center.'**
  String get errAccountInactive;

  /// No description provided for @errFirestoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Signed in, but the database did not answer. Check that Firestore is created in your Firebase project.'**
  String get errFirestoreUnavailable;

  /// No description provided for @errRulesDenied.
  ///
  /// In en, this message translates to:
  /// **'The database refused the request. Deploy the Firestore rules: firebase deploy --only firestore:rules'**
  String get errRulesDenied;

  /// No description provided for @errSetupAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'Setup is already done on this project. Sign in instead.'**
  String get errSetupAlreadyDone;

  /// No description provided for @errNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured yet. Run flutterfire configure.'**
  String get errNotConfigured;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnknown;

  /// No description provided for @failPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this. Ask the admin, or deploy the Firestore rules.'**
  String get failPermission;

  /// No description provided for @failIndex.
  ///
  /// In en, this message translates to:
  /// **'This list needs a database index. Deploy firestore.indexes.json.'**
  String get failIndex;

  /// No description provided for @failNotFound.
  ///
  /// In en, this message translates to:
  /// **'It no longer exists.'**
  String get failNotFound;

  /// No description provided for @failUpload.
  ///
  /// In en, this message translates to:
  /// **'The upload did not finish. Try again.'**
  String get failUpload;

  /// No description provided for @typeVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get typeVideos;

  /// No description provided for @typePdfs.
  ///
  /// In en, this message translates to:
  /// **'PDFs'**
  String get typePdfs;

  /// No description provided for @typeImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get typeImages;

  /// No description provided for @typeExams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get typeExams;

  /// No description provided for @typeQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get typeQuizzes;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @lateStatus.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateStatus;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If that email has an account, a reset link is on its way.'**
  String get resetEmailSent;

  /// No description provided for @consoleHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your whole center, one screen.'**
  String get consoleHeadline;

  /// No description provided for @consoleSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Lessons, exams, attendance and parents — organised.'**
  String get consoleSubheadline;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your center'**
  String get setupTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create the first admin account. This works once per project.'**
  String get setupSubtitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the account the center gave you.'**
  String get signInSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amr Mesbah'**
  String get fullNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create admin account'**
  String get createAdminAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @setupCenter.
  ///
  /// In en, this message translates to:
  /// **'First time? Set up the center'**
  String get setupCenter;

  /// No description provided for @consoleAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Admins and teachers sign in here. Students and parents use the phone app.'**
  String get consoleAccountsHint;

  /// No description provided for @tabletAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone signs in here — students, parents, teachers and admins.'**
  String get tabletAccountsHint;

  /// No description provided for @mobileAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Students and parents sign in here. Teachers use a tablet or computer.'**
  String get mobileAccountsHint;

  /// No description provided for @wrongDeviceMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Open this account on a phone or tablet'**
  String get wrongDeviceMobileTitle;

  /// No description provided for @wrongDeviceDesktopTitle.
  ///
  /// In en, this message translates to:
  /// **'Open this account on a tablet or computer'**
  String get wrongDeviceDesktopTitle;

  /// No description provided for @wrongDeviceMobileBody.
  ///
  /// In en, this message translates to:
  /// **'{role} accounts use the Manger Plus app on a phone or tablet. Install it there and sign in with the same email.'**
  String wrongDeviceMobileBody(String role);

  /// No description provided for @wrongDeviceDesktopBody.
  ///
  /// In en, this message translates to:
  /// **'{role} accounts use the console on a tablet or computer. Open Manger Plus there and sign in with the same email.'**
  String wrongDeviceDesktopBody(String role);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @debugPreviewAnyway.
  ///
  /// In en, this message translates to:
  /// **'Preview anyway (debug build)'**
  String get debugPreviewAnyway;

  /// No description provided for @debugPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Only in debug builds. Reset it from Settings.'**
  String get debugPreviewHint;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @teachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachers;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @sections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get sections;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @myStudents.
  ///
  /// In en, this message translates to:
  /// **'My students'**
  String get myStudents;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need your email and password to come back.'**
  String get signOutBody;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// No description provided for @overviewAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Here is your center today.'**
  String get overviewAdminSub;

  /// No description provided for @overviewTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Your classes, content and results at a glance.'**
  String get overviewTeacherSub;

  /// No description provided for @contentLibrary.
  ///
  /// In en, this message translates to:
  /// **'Content library'**
  String get contentLibrary;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(String count);

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get recentlyAdded;

  /// No description provided for @noContentYet.
  ///
  /// In en, this message translates to:
  /// **'No content yet.'**
  String get noContentYet;

  /// No description provided for @demoFailed.
  ///
  /// In en, this message translates to:
  /// **'Demo data could not be written'**
  String get demoFailed;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo data'**
  String get demoTitle;

  /// No description provided for @demoBody.
  ///
  /// In en, this message translates to:
  /// **'Fills Firebase with sections, teachers, students, parents, lessons, exams, results, attendance and a conversation. Every demo account\'s password is {password}.'**
  String demoBody(String password);

  /// No description provided for @removeDemo.
  ///
  /// In en, this message translates to:
  /// **'Remove demo data'**
  String get removeDemo;

  /// No description provided for @removeDemoQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove all demo data?'**
  String get removeDemoQuestion;

  /// No description provided for @removeDemoBody.
  ///
  /// In en, this message translates to:
  /// **'Deletes every record marked as demo. Your own data is not touched.'**
  String get removeDemoBody;

  /// No description provided for @demoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Demo data removed'**
  String get demoRemoved;

  /// No description provided for @fillDemo.
  ///
  /// In en, this message translates to:
  /// **'Fill demo data'**
  String get fillDemo;

  /// No description provided for @demoFilled.
  ///
  /// In en, this message translates to:
  /// **'Demo data is ready — try signing in as sara@demo.mangerplus.app'**
  String get demoFilled;

  /// No description provided for @myContent.
  ///
  /// In en, this message translates to:
  /// **'My content'**
  String get myContent;

  /// No description provided for @resultsReceived.
  ///
  /// In en, this message translates to:
  /// **'Results received'**
  String get resultsReceived;

  /// No description provided for @yourPermissions.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get yourPermissions;

  /// No description provided for @yourPermissionsSub.
  ///
  /// In en, this message translates to:
  /// **'Set by the admin. Ask them if something you need is missing.'**
  String get yourPermissionsSub;

  /// No description provided for @nobodyFound.
  ///
  /// In en, this message translates to:
  /// **'Nobody matches that search.'**
  String get nobodyFound;

  /// No description provided for @addTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add teacher'**
  String get addTeacher;

  /// No description provided for @editTeacher.
  ///
  /// In en, this message translates to:
  /// **'Edit teacher'**
  String get editTeacher;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In en, this message translates to:
  /// **'Edit student'**
  String get editStudent;

  /// No description provided for @addParent.
  ///
  /// In en, this message translates to:
  /// **'Add parent'**
  String get addParent;

  /// No description provided for @editParent.
  ///
  /// In en, this message translates to:
  /// **'Edit parent'**
  String get editParent;

  /// No description provided for @accountCreateHint.
  ///
  /// In en, this message translates to:
  /// **'They sign in with this email and password.'**
  String get accountCreateHint;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @passwordShareHint.
  ///
  /// In en, this message translates to:
  /// **'Share it with them privately. At least 6 characters.'**
  String get passwordShareHint;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics'**
  String get subjectHint;

  /// No description provided for @teachesSections.
  ///
  /// In en, this message translates to:
  /// **'Teaches these sections'**
  String get teachesSections;

  /// No description provided for @noSectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sections yet — add them in Sections.'**
  String get noSectionsYet;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @accountActive.
  ///
  /// In en, this message translates to:
  /// **'Account active'**
  String get accountActive;

  /// No description provided for @accountActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Switch off to block sign-in without deleting anything.'**
  String get accountActiveHint;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteQuestion(String name);

  /// No description provided for @deletePersonBody.
  ///
  /// In en, this message translates to:
  /// **'Their profile is removed and they can no longer sign in. Their results and attendance stay on record.'**
  String get deletePersonBody;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @noSection.
  ///
  /// In en, this message translates to:
  /// **'No section'**
  String get noSection;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get inactive;

  /// No description provided for @switchOff.
  ///
  /// In en, this message translates to:
  /// **'Switch off'**
  String get switchOff;

  /// No description provided for @switchOn.
  ///
  /// In en, this message translates to:
  /// **'Switch on'**
  String get switchOn;

  /// No description provided for @peopleSub.
  ///
  /// In en, this message translates to:
  /// **'Create accounts, set sections and control access.'**
  String get peopleSub;

  /// No description provided for @nobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet'**
  String get nobodyYet;

  /// No description provided for @nobodyYetSub.
  ///
  /// In en, this message translates to:
  /// **'Add the first one with the button above, or fill demo data from the Overview.'**
  String get nobodyYetSub;

  /// No description provided for @deleteSectionWithStudents.
  ///
  /// In en, this message translates to:
  /// **'{count} students are in this section. They will be left without a section until you move them.'**
  String deleteSectionWithStudents(String count);

  /// No description provided for @deleteSectionBody.
  ///
  /// In en, this message translates to:
  /// **'The section is removed. Content assigned to it stops showing for it.'**
  String get deleteSectionBody;

  /// No description provided for @sectionsSub.
  ///
  /// In en, this message translates to:
  /// **'Group students into classes. Content, attendance and teachers are organised by section.'**
  String get sectionsSub;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get addSection;

  /// No description provided for @editSection.
  ///
  /// In en, this message translates to:
  /// **'Edit section'**
  String get editSection;

  /// No description provided for @noSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No sections yet'**
  String get noSectionsTitle;

  /// No description provided for @noSectionsSub.
  ///
  /// In en, this message translates to:
  /// **'Create your first class group, then add students to it.'**
  String get noSectionsSub;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String studentsCount(String count);

  /// No description provided for @teachersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} teachers'**
  String teachersCount(String count);

  /// No description provided for @sectionName.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get sectionName;

  /// No description provided for @sectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grade 7 — A'**
  String get sectionNameHint;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @levelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grade 7'**
  String get levelHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addQuestion;

  /// No description provided for @questionText.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionText;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @optionN.
  ///
  /// In en, this message translates to:
  /// **'Option {n}'**
  String optionN(String n);

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// No description provided for @markCorrectHint.
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer'**
  String get markCorrectHint;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That file is larger than {mb} MB.'**
  String fileTooLarge(String mb);

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitle;

  /// No description provided for @enterValidLink.
  ///
  /// In en, this message translates to:
  /// **'Enter a full link starting with https://'**
  String get enterValidLink;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get chooseFile;

  /// No description provided for @questionsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Every question needs text, at least two options and a correct answer.'**
  String get questionsIncomplete;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New {type}'**
  String newItem(String type);

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit {type}'**
  String editItem(String type);

  /// No description provided for @assessmentHint.
  ///
  /// In en, this message translates to:
  /// **'Multiple-choice questions, marked automatically when the student submits.'**
  String get assessmentHint;

  /// No description provided for @fileHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a file to Firebase Storage, or paste a link.'**
  String get fileHint;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What should students do with it?'**
  String get descriptionHint;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get uploadFile;

  /// No description provided for @pasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get pasteLink;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get timeLimit;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @zeroUntimed.
  ///
  /// In en, this message translates to:
  /// **'0 = no time limit'**
  String get zeroUntimed;

  /// No description provided for @questionsTotal.
  ///
  /// In en, this message translates to:
  /// **'Questions — {count} questions, {points} points'**
  String questionsTotal(String count, String points);

  /// No description provided for @assignToSections.
  ///
  /// In en, this message translates to:
  /// **'Assign to sections'**
  String get assignToSections;

  /// No description provided for @noSectionsAssigned.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any section yet. Ask the admin.'**
  String get noSectionsAssigned;

  /// No description provided for @assignToStudents.
  ///
  /// In en, this message translates to:
  /// **'…or to single students'**
  String get assignToStudents;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date — tap to set one'**
  String get noDueDate;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @publishedHint.
  ///
  /// In en, this message translates to:
  /// **'Off keeps it as a draft only you can see.'**
  String get publishedHint;

  /// No description provided for @notAssignedWarning.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to anyone yet — no student will see it.'**
  String get notAssignedWarning;

  /// No description provided for @allowedTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed: {types}'**
  String allowedTypes(String types);

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @uploadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String uploadingPercent(String percent);

  /// No description provided for @deleteAssessmentBody.
  ///
  /// In en, this message translates to:
  /// **'Students will no longer see it. Results already submitted stay in Grades.'**
  String get deleteAssessmentBody;

  /// No description provided for @deleteContentBody.
  ///
  /// In en, this message translates to:
  /// **'Students will no longer see it, and the uploaded file is deleted.'**
  String get deleteContentBody;

  /// No description provided for @contentAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Everything every teacher has published.'**
  String get contentAdminSub;

  /// No description provided for @contentTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Upload lessons and build exams, then assign them to a section or to single students.'**
  String get contentTeacherSub;

  /// No description provided for @addContent.
  ///
  /// In en, this message translates to:
  /// **'Add content'**
  String get addContent;

  /// No description provided for @noContentPermission.
  ///
  /// In en, this message translates to:
  /// **'The admin has not given you permission to publish content yet.'**
  String get noContentPermission;

  /// No description provided for @noContentSub.
  ///
  /// In en, this message translates to:
  /// **'Use “Add content” to upload your first lesson or build a quiz.'**
  String get noContentSub;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @questionsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} questions · {time}'**
  String questionsShort(String count, String time);

  /// No description provided for @untimed.
  ///
  /// In en, this message translates to:
  /// **'untimed'**
  String get untimed;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutesShort(String n);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved'**
  String get attendanceSaved;

  /// No description provided for @attendanceSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a section and a day, tap each student\'s status, then save.'**
  String get attendanceSub;

  /// No description provided for @noStudentsInSection.
  ///
  /// In en, this message translates to:
  /// **'No students in this section'**
  String get noStudentsInSection;

  /// No description provided for @noStudentsInSectionSub.
  ///
  /// In en, this message translates to:
  /// **'The admin adds students to sections from the Students page.'**
  String get noStudentsInSectionSub;

  /// No description provided for @unmarkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not marked'**
  String unmarkedCount(String count);

  /// No description provided for @markAllPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark all present'**
  String get markAllPresent;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @notSavedYet.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet'**
  String get notSavedYet;

  /// No description provided for @gradesSub.
  ///
  /// In en, this message translates to:
  /// **'Results arrive here the moment a student submits. Adjust a mark or add feedback any time.'**
  String get gradesSub;

  /// No description provided for @noAssessments.
  ///
  /// In en, this message translates to:
  /// **'No exams or quizzes yet'**
  String get noAssessments;

  /// No description provided for @noAssessmentsSub.
  ///
  /// In en, this message translates to:
  /// **'Create one from the Content page.'**
  String get noAssessmentsSub;

  /// No description provided for @pointsTotal.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsTotal(String points);

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @notSubmittedYet.
  ///
  /// In en, this message translates to:
  /// **'Not submitted yet'**
  String get notSubmittedYet;

  /// No description provided for @gradedByTeacher.
  ///
  /// In en, this message translates to:
  /// **'Graded by teacher'**
  String get gradedByTeacher;

  /// No description provided for @autoMarked.
  ///
  /// In en, this message translates to:
  /// **'Auto-marked'**
  String get autoMarked;

  /// No description provided for @enterGrade.
  ///
  /// In en, this message translates to:
  /// **'Enter grade'**
  String get enterGrade;

  /// No description provided for @editGrade.
  ///
  /// In en, this message translates to:
  /// **'Edit grade'**
  String get editGrade;

  /// No description provided for @scoreRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a score from 0 to {max}.'**
  String scoreRange(String max);

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Visible to the student and their parents.'**
  String get feedbackHint;

  /// No description provided for @aboutAssignment.
  ///
  /// In en, this message translates to:
  /// **'About an assignment'**
  String get aboutAssignment;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noMessagesYetSub.
  ///
  /// In en, this message translates to:
  /// **'Say hello — messages arrive instantly.'**
  String get noMessagesYetSub;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About: {title}'**
  String aboutTitle(String title);

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get typeMessage;

  /// No description provided for @aboutChild.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String aboutChild(String name);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @messagesTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Conversations with parents, one thread per child.'**
  String get messagesTeacherSub;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @noConversationsTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Parents can write to you from their app, or start one from My students.'**
  String get noConversationsTeacherSub;

  /// No description provided for @parentOf.
  ///
  /// In en, this message translates to:
  /// **'Parent of {name}'**
  String parentOf(String name);

  /// No description provided for @myStudentsSub.
  ///
  /// In en, this message translates to:
  /// **'Students in the sections you teach. Click one for results, attendance and parents.'**
  String get myStudentsSub;

  /// No description provided for @noParentsLinked.
  ///
  /// In en, this message translates to:
  /// **'No parent linked yet. The admin links parents from the Parents page.'**
  String get noParentsLinked;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @noAttendanceYet.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded yet.'**
  String get noAttendanceYet;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance {percent}%'**
  String attendanceRate(String percent);

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet.'**
  String get noResultsYet;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration on tap'**
  String get haptics;

  /// No description provided for @branding.
  ///
  /// In en, this message translates to:
  /// **'Brand colours'**
  String get branding;

  /// No description provided for @resetColors.
  ///
  /// In en, this message translates to:
  /// **'Reset to default colours'**
  String get resetColors;

  /// No description provided for @brandingLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this computer.'**
  String get brandingLocalHint;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @clearDeviceOverride.
  ///
  /// In en, this message translates to:
  /// **'Clear device preview'**
  String get clearDeviceOverride;

  /// No description provided for @clearDeviceOverrideSub.
  ///
  /// In en, this message translates to:
  /// **'Stops pretending this device is a phone / computer, and signs out.'**
  String get clearDeviceOverrideSub;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startNow;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(String count);

  /// No description provided for @openExternally.
  ///
  /// In en, this message translates to:
  /// **'Open in another app'**
  String get openExternally;

  /// No description provided for @videoFailed.
  ///
  /// In en, this message translates to:
  /// **'This video could not be played. Try opening it in another app.'**
  String get videoFailed;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String pageOf(String page, String pages);

  /// No description provided for @pdfFailed.
  ///
  /// In en, this message translates to:
  /// **'This PDF could not be opened here. Tap to open it in another app.'**
  String get pdfFailed;

  /// No description provided for @pinchToZoom.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get pinchToZoom;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @notTakenYet.
  ///
  /// In en, this message translates to:
  /// **'{name} has not taken this yet.'**
  String notTakenYet(String name);

  /// No description provided for @examRules.
  ///
  /// In en, this message translates to:
  /// **'Answer every question, then submit. You can move between questions freely. You can submit only once.'**
  String get examRules;

  /// No description provided for @startExam.
  ///
  /// In en, this message translates to:
  /// **'Start {type}'**
  String startExam(String type);

  /// No description provided for @submitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Submit your answers?'**
  String get submitQuestion;

  /// No description provided for @submitWithBlanks.
  ///
  /// In en, this message translates to:
  /// **'{count} questions are still blank. You cannot change answers after submitting.'**
  String submitWithBlanks(String count);

  /// No description provided for @submitBody.
  ///
  /// In en, this message translates to:
  /// **'You cannot change answers after submitting.'**
  String get submitBody;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @submitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit'**
  String get submitFailed;

  /// No description provided for @alreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted this one.'**
  String get alreadySubmitted;

  /// No description provided for @leaveExamQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave without submitting?'**
  String get leaveExamQuestion;

  /// No description provided for @leaveExamBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers will be lost.'**
  String get leaveExamBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @questionNofM.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {m}'**
  String questionNofM(String n, String m);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up — your answers were submitted automatically.'**
  String get timeUp;

  /// No description provided for @submittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted!'**
  String get submittedTitle;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @verdictExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent work!'**
  String get verdictExcellent;

  /// No description provided for @verdictGood.
  ///
  /// In en, this message translates to:
  /// **'Good job!'**
  String get verdictGood;

  /// No description provided for @verdictPass.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get verdictPass;

  /// No description provided for @verdictKeepTrying.
  ///
  /// In en, this message translates to:
  /// **'Keep practising'**
  String get verdictKeepTrying;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @libraryTab.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @nothingAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned yet'**
  String get nothingAssignedYet;

  /// No description provided for @nothingAssignedYetSub.
  ///
  /// In en, this message translates to:
  /// **'When your teachers share lessons, exams or quizzes, they will appear here.'**
  String get nothingAssignedYetSub;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearning;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @newThisWeek.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newThisWeek;

  /// No description provided for @toDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get toDo;

  /// No description provided for @searchLessons.
  ///
  /// In en, this message translates to:
  /// **'Search lessons, exams, teachers…'**
  String get searchLessons;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get nothingHere;

  /// No description provided for @nothingHereSub.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search.'**
  String get nothingHereSub;

  /// No description provided for @averageGrade.
  ///
  /// In en, this message translates to:
  /// **'Average grade'**
  String get averageGrade;

  /// No description provided for @resultsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCountLabel(String count);

  /// No description provided for @daysRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} days recorded'**
  String daysRecorded(String count);

  /// No description provided for @lastDays.
  ///
  /// In en, this message translates to:
  /// **'Latest days'**
  String get lastDays;

  /// No description provided for @absencesAndLate.
  ///
  /// In en, this message translates to:
  /// **'Absences and late days'**
  String get absencesAndLate;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My progress'**
  String get myProgress;

  /// No description provided for @noChildrenLinked.
  ///
  /// In en, this message translates to:
  /// **'No children linked yet'**
  String get noChildrenLinked;

  /// No description provided for @noChildrenLinkedSub.
  ///
  /// In en, this message translates to:
  /// **'Ask the center to link your children to your account.'**
  String get noChildrenLinkedSub;

  /// No description provided for @yourChildren.
  ///
  /// In en, this message translates to:
  /// **'Your children'**
  String get yourChildren;

  /// No description provided for @messageATeacher.
  ///
  /// In en, this message translates to:
  /// **'Message a teacher'**
  String get messageATeacher;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @chooseTeacher.
  ///
  /// In en, this message translates to:
  /// **'Choose a teacher'**
  String get chooseTeacher;

  /// No description provided for @noTeachersToMessage.
  ///
  /// In en, this message translates to:
  /// **'No teacher of this section can receive messages yet.'**
  String get noTeachersToMessage;

  /// No description provided for @whichChild.
  ///
  /// In en, this message translates to:
  /// **'Which child is this about?'**
  String get whichChild;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @noConversationsParentSub.
  ///
  /// In en, this message translates to:
  /// **'Tap “New message” to write to one of your child\'s teachers.'**
  String get noConversationsParentSub;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Attendance, results and content across the whole center.'**
  String get dashboardAdminSub;

  /// No description provided for @dashboardTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Attendance and results for the sections you teach.'**
  String get dashboardTeacherSub;

  /// No description provided for @attendanceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get attendanceRateLabel;

  /// No description provided for @averageScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get averageScoreLabel;

  /// No description provided for @gradedResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Results marked'**
  String get gradedResultsLabel;

  /// No description provided for @publishedContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Published content'**
  String get publishedContentLabel;

  /// No description provided for @attendanceByStatus.
  ///
  /// In en, this message translates to:
  /// **'Attendance by status'**
  String get attendanceByStatus;

  /// No description provided for @attendanceByDay.
  ///
  /// In en, this message translates to:
  /// **'Attendance by day'**
  String get attendanceByDay;

  /// No description provided for @averageBySection.
  ///
  /// In en, this message translates to:
  /// **'Average score by section'**
  String get averageBySection;

  /// No description provided for @scoreBands.
  ///
  /// In en, this message translates to:
  /// **'Score bands'**
  String get scoreBands;

  /// No description provided for @resultsByType.
  ///
  /// In en, this message translates to:
  /// **'Results by type'**
  String get resultsByType;

  /// No description provided for @band0.
  ///
  /// In en, this message translates to:
  /// **'Below 50'**
  String get band0;

  /// No description provided for @band50.
  ///
  /// In en, this message translates to:
  /// **'50–64'**
  String get band50;

  /// No description provided for @band65.
  ///
  /// In en, this message translates to:
  /// **'65–79'**
  String get band65;

  /// No description provided for @band80.
  ///
  /// In en, this message translates to:
  /// **'80–100'**
  String get band80;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// No description provided for @period30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get period30;

  /// No description provided for @period90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get period90;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @onlyBelowPass.
  ///
  /// In en, this message translates to:
  /// **'Only results below 50%'**
  String get onlyBelowPass;

  /// No description provided for @onlyAbsences.
  ///
  /// In en, this message translates to:
  /// **'Only absences and late days'**
  String get onlyAbsences;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportFileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get exportFileName;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String exportSaved(String path);

  /// No description provided for @exportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailedTitle;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get exportCancelled;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessment;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @rowsShown.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total}'**
  String rowsShown(String shown, String total);

  /// No description provided for @nothingToChart.
  ///
  /// In en, this message translates to:
  /// **'Nothing to chart yet'**
  String get nothingToChart;

  /// No description provided for @nothingToChartSub.
  ///
  /// In en, this message translates to:
  /// **'Charts fill in as attendance is taken and assessments are marked.'**
  String get nothingToChartSub;

  /// No description provided for @noRowsMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get noRowsMatch;

  /// No description provided for @dashboardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a student or an assessment'**
  String get dashboardSearchHint;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @enterFileName.
  ///
  /// In en, this message translates to:
  /// **'Enter a file name'**
  String get enterFileName;

  /// No description provided for @focusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue — finish it first'**
  String get focusOverdue;

  /// No description provided for @focusNext.
  ///
  /// In en, this message translates to:
  /// **'Your next task'**
  String get focusNext;

  /// No description provided for @focusNew.
  ///
  /// In en, this message translates to:
  /// **'New for you'**
  String get focusNew;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpSub.
  ///
  /// In en, this message translates to:
  /// **'No exams or quizzes waiting. A good moment to review a lesson.'**
  String get allCaughtUpSub;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'Due in {n} days'**
  String dueInDays(String n);

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days overdue'**
  String overdueByDays(String n);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @notRecordedToday.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet'**
  String get notRecordedToday;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @latestResult.
  ///
  /// In en, this message translates to:
  /// **'Latest result'**
  String get latestResult;

  /// No description provided for @aboveAverage.
  ///
  /// In en, this message translates to:
  /// **'{n} pts above your average'**
  String aboveAverage(String n);

  /// No description provided for @belowAverage.
  ///
  /// In en, this message translates to:
  /// **'{n} pts below your average'**
  String belowAverage(String n);

  /// No description provided for @onYourAverage.
  ///
  /// In en, this message translates to:
  /// **'Right on your average'**
  String get onYourAverage;

  /// No description provided for @assessmentsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} exams & quizzes done'**
  String assessmentsDone(String done, String total);

  /// No description provided for @atAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get atAGlance;

  /// No description provided for @noResultYetShort.
  ///
  /// In en, this message translates to:
  /// **'Your first result will show here.'**
  String get noResultYetShort;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
