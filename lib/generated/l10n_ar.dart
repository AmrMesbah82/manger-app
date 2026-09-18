// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مستقبل';

  @override
  String get appTagline => 'التعلم بشكل منظم';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get roleTeacher => 'معلم';

  @override
  String get roleStudent => 'طالب';

  @override
  String get roleParent => 'ولي أمر';

  @override
  String get typeVideo => 'فيديو';

  @override
  String get typePdf => 'ملف PDF';

  @override
  String get typeImage => 'صورة';

  @override
  String get typeExam => 'امتحان';

  @override
  String get typeQuiz => 'اختبار قصير';

  @override
  String get attendance => 'الحضور';

  @override
  String get grades => 'الدرجات';

  @override
  String get messages => 'الرسائل';

  @override
  String permissionPublishDesc(String type) {
    return 'يمكنه إضافة وتعديل وحذف محتوى $type';
  }

  @override
  String get permissionAttendanceDesc => 'يمكنه تسجيل الحضور لفصوله';

  @override
  String get permissionGradesDesc => 'يمكنه مراجعة نتائج الطلاب ورصد الدرجات';

  @override
  String get permissionMessagesDesc => 'يمكنه مراسلة أولياء الأمور';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get discard => 'تجاهل';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get search => 'بحث';

  @override
  String get all => 'الكل';

  @override
  String get primaryColor => 'اللون الأساسي';

  @override
  String get secondaryColor => 'اللون الثانوي';

  @override
  String get colors => 'الألوان';

  @override
  String get errWrongCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errInvalidEmail => 'البريد الإلكتروني غير صالح.';

  @override
  String get errEmailInUse => 'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get errWeakPassword => 'استخدم 6 أحرف على الأقل لكلمة المرور.';

  @override
  String get errUserDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get errTooManyRequests =>
      'محاولات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.';

  @override
  String get errNetwork => 'لا يوجد اتصال. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get errProfileMissing =>
      'هذا الحساب ليس له ملف. اطلب من المدير إنشاءه من لوحة التحكم.';

  @override
  String get errAccountInactive => 'هذا الحساب موقوف. تواصل مع المركز.';

  @override
  String get errFirestoreUnavailable =>
      'تم تسجيل الدخول لكن قاعدة البيانات لم تستجب. تأكد من إنشاء Firestore في مشروع Firebase.';

  @override
  String get errRulesDenied =>
      'رفضت قاعدة البيانات الطلب. انشر قواعد Firestore: firebase deploy --only firestore:rules';

  @override
  String get errSetupAlreadyDone =>
      'تم الإعداد بالفعل لهذا المشروع. سجّل الدخول.';

  @override
  String get errNotConfigured =>
      'لم يتم إعداد Firebase بعد. شغّل flutterfire configure.';

  @override
  String get errUnknown => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get failPermission =>
      'ليس لديك صلاحية لذلك. اطلب من المدير أو انشر قواعد Firestore.';

  @override
  String get failIndex =>
      'تحتاج هذه القائمة إلى فهرس. انشر firestore.indexes.json.';

  @override
  String get failNotFound => 'لم يعد موجودًا.';

  @override
  String get failUpload => 'لم يكتمل الرفع. حاول مرة أخرى.';

  @override
  String get typeVideos => 'الفيديوهات';

  @override
  String get typePdfs => 'ملفات PDF';

  @override
  String get typeImages => 'الصور';

  @override
  String get typeExams => 'الامتحانات';

  @override
  String get typeQuizzes => 'الاختبارات القصيرة';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get lateStatus => 'متأخر';

  @override
  String get excused => 'بعذر';

  @override
  String get resetEmailSent =>
      'إذا كان لهذا البريد حساب، فسيصلك رابط إعادة التعيين.';

  @override
  String get consoleHeadline => 'مركزك بالكامل في شاشة واحدة.';

  @override
  String get consoleSubheadline =>
      'الدروس والامتحانات والحضور وأولياء الأمور — بشكل منظم.';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get enterName => 'أدخل الاسم';

  @override
  String get setupTitle => 'إعداد المركز';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get setupSubtitle =>
      'أنشئ حساب المدير الأول. يعمل هذا مرة واحدة فقط لكل مشروع.';

  @override
  String get signInSubtitle => 'سجّل الدخول بالحساب الذي أعطاك إياه المركز.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'مثال: عمرو مصباح';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get createAdminAccount => 'إنشاء حساب المدير';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get backToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get setupCenter => 'أول مرة؟ قم بإعداد المركز';

  @override
  String get consoleAccountsHint =>
      'يسجّل المدير والمعلمون الدخول هنا. يستخدم الطلاب وأولياء الأمور تطبيق الهاتف.';

  @override
  String get tabletAccountsHint =>
      'يسجّل الجميع الدخول هنا — الطلاب وأولياء الأمور والمعلمون والمديرون.';

  @override
  String get mobileAccountsHint =>
      'يسجّل الطلاب وأولياء الأمور الدخول هنا. يستخدم المعلمون جهازًا لوحيًا أو كمبيوتر.';

  @override
  String get wrongDeviceMobileTitle => 'افتح هذا الحساب على هاتف أو جهاز لوحي';

  @override
  String get wrongDeviceDesktopTitle =>
      'افتح هذا الحساب على جهاز لوحي أو كمبيوتر';

  @override
  String wrongDeviceMobileBody(String role) {
    return 'حسابات $role تستخدم تطبيق مستقبل على الهاتف أو الجهاز اللوحي. ثبّته هناك وسجّل الدخول بنفس البريد.';
  }

  @override
  String wrongDeviceDesktopBody(String role) {
    return 'حسابات $role تستخدم لوحة التحكم على الجهاز اللوحي أو الكمبيوتر. افتح مستقبل هناك وسجّل الدخول بنفس البريد.';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get debugPreviewAnyway => 'معاينة على أي حال (نسخة التطوير)';

  @override
  String get debugPreviewHint =>
      'فقط في نسخة التطوير. يمكنك إلغاؤه من الإعدادات.';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get teachers => 'المعلمون';

  @override
  String get students => 'الطلاب';

  @override
  String get parents => 'أولياء الأمور';

  @override
  String get sections => 'الفصول';

  @override
  String get content => 'المحتوى';

  @override
  String get myStudents => 'طلابي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get signOutQuestion => 'تسجيل الخروج؟';

  @override
  String get signOutBody => 'ستحتاج بريدك وكلمة المرور للعودة.';

  @override
  String helloName(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get overviewAdminSub => 'هذه نظرة على مركزك اليوم.';

  @override
  String get overviewTeacherSub => 'فصولك ومحتواك ونتائجك في لمحة.';

  @override
  String get contentLibrary => 'مكتبة المحتوى';

  @override
  String itemsCount(String count) {
    return '$count عنصر';
  }

  @override
  String get recentlyAdded => 'أضيف مؤخرًا';

  @override
  String get noContentYet => 'لا يوجد محتوى بعد.';

  @override
  String get demoFailed => 'تعذّر إنشاء البيانات التجريبية';

  @override
  String get demoTitle => 'بيانات تجريبية';

  @override
  String demoBody(String password) {
    return 'يملأ Firebase بفصول ومعلمين وطلاب وأولياء أمور ودروس وامتحانات ونتائج وحضور ومحادثة. كلمة مرور كل حساب تجريبي هي $password.';
  }

  @override
  String get removeDemo => 'حذف البيانات التجريبية';

  @override
  String get removeDemoQuestion => 'حذف كل البيانات التجريبية؟';

  @override
  String get removeDemoBody => 'يحذف كل سجل تجريبي. بياناتك الحقيقية لن تتأثر.';

  @override
  String get demoRemoved => 'تم حذف البيانات التجريبية';

  @override
  String get fillDemo => 'إنشاء بيانات تجريبية';

  @override
  String get demoFilled =>
      'البيانات التجريبية جاهزة — جرّب الدخول بـ sara@demo.mangerplus.app';

  @override
  String get myContent => 'محتواي';

  @override
  String get resultsReceived => 'النتائج المستلمة';

  @override
  String get yourPermissions => 'صلاحياتك';

  @override
  String get yourPermissionsSub =>
      'يحددها المدير. اطلب منه إن احتجت شيئًا غير متاح.';

  @override
  String get nobodyFound => 'لا يوجد أحد يطابق البحث.';

  @override
  String get addTeacher => 'إضافة معلم';

  @override
  String get editTeacher => 'تعديل المعلم';

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get editStudent => 'تعديل الطالب';

  @override
  String get addParent => 'إضافة ولي أمر';

  @override
  String get editParent => 'تعديل ولي الأمر';

  @override
  String get accountCreateHint => 'سيسجّل الدخول بهذا البريد وكلمة المرور.';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get phone => 'الهاتف';

  @override
  String get passwordShareHint => 'شاركها معه بشكل خاص. 6 أحرف على الأقل.';

  @override
  String get generate => 'توليد';

  @override
  String get subject => 'المادة';

  @override
  String get subjectHint => 'مثال: الرياضيات';

  @override
  String get teachesSections => 'يدرّس هذه الفصول';

  @override
  String get noSectionsYet => 'لا توجد فصول بعد — أضفها من صفحة الفصول.';

  @override
  String get permissions => 'الصلاحيات';

  @override
  String get section => 'الفصل';

  @override
  String get children => 'الأبناء';

  @override
  String get accountActive => 'الحساب مفعّل';

  @override
  String get accountActiveHint => 'أوقفه لمنع الدخول دون حذف أي بيانات.';

  @override
  String get roleLabel => 'الدور';

  @override
  String get saved => 'تم الحفظ';

  @override
  String deleteQuestion(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deletePersonBody =>
      'سيُحذف ملفه ولن يتمكن من الدخول. تبقى نتائجه وحضوره محفوظة.';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get name => 'الاسم';

  @override
  String get noSection => 'بدون فصل';

  @override
  String get status => 'الحالة';

  @override
  String get active => 'مفعّل';

  @override
  String get inactive => 'موقوف';

  @override
  String get switchOff => 'إيقاف';

  @override
  String get switchOn => 'تفعيل';

  @override
  String get peopleSub => 'أنشئ الحسابات وحدد الفصول وتحكم في الصلاحيات.';

  @override
  String get nobodyYet => 'لا يوجد أحد بعد';

  @override
  String get nobodyYetSub =>
      'أضف أول شخص من الزر بالأعلى، أو أنشئ بيانات تجريبية من صفحة النظرة العامة.';

  @override
  String deleteSectionWithStudents(String count) {
    return 'يوجد $count طالب في هذا الفصل. سيبقون بدون فصل حتى تنقلهم.';
  }

  @override
  String get deleteSectionBody => 'سيُحذف الفصل ولن يظهر المحتوى المخصص له.';

  @override
  String get sectionsSub =>
      'قسّم الطلاب إلى فصول. المحتوى والحضور والمعلمون منظمون حسب الفصل.';

  @override
  String get addSection => 'إضافة فصل';

  @override
  String get editSection => 'تعديل الفصل';

  @override
  String get noSectionsTitle => 'لا توجد فصول بعد';

  @override
  String get noSectionsSub => 'أنشئ أول فصل ثم أضف إليه الطلاب.';

  @override
  String studentsCount(String count) {
    return '$count طالب';
  }

  @override
  String teachersCount(String count) {
    return '$count معلم';
  }

  @override
  String get sectionName => 'اسم الفصل';

  @override
  String get sectionNameHint => 'مثال: الصف السابع — أ';

  @override
  String get level => 'المستوى';

  @override
  String get levelHint => 'مثال: الصف السابع';

  @override
  String get description => 'الوصف';

  @override
  String get addQuestion => 'إضافة سؤال';

  @override
  String get questionText => 'السؤال';

  @override
  String get points => 'الدرجة';

  @override
  String optionN(String n) {
    return 'الاختيار $n';
  }

  @override
  String get addOption => 'إضافة اختيار';

  @override
  String get markCorrectHint => 'حدّد الإجابة الصحيحة';

  @override
  String fileTooLarge(String mb) {
    return 'الملف أكبر من $mb ميجابايت.';
  }

  @override
  String get enterTitle => 'أدخل العنوان';

  @override
  String get enterValidLink => 'أدخل رابطًا كاملًا يبدأ بـ https://';

  @override
  String get chooseFile => 'اختر ملفًا';

  @override
  String get questionsIncomplete =>
      'كل سؤال يحتاج نصًا واختيارين على الأقل وإجابة صحيحة.';

  @override
  String newItem(String type) {
    return '$type جديد';
  }

  @override
  String editItem(String type) {
    return 'تعديل $type';
  }

  @override
  String get assessmentHint =>
      'أسئلة اختيار من متعدد تُصحّح تلقائيًا عند تسليم الطالب.';

  @override
  String get fileHint => 'ارفع ملفًا إلى Firebase Storage أو الصق رابطًا.';

  @override
  String get title => 'العنوان';

  @override
  String get descriptionHint => 'ماذا يجب أن يفعل الطلاب به؟';

  @override
  String get file => 'الملف';

  @override
  String get uploadFile => 'رفع ملف';

  @override
  String get pasteLink => 'لصق رابط';

  @override
  String get link => 'الرابط';

  @override
  String get timeLimit => 'المدة';

  @override
  String get minutes => 'دقائق';

  @override
  String get zeroUntimed => '0 = بدون حد زمني';

  @override
  String questionsTotal(String count, String points) {
    return 'الأسئلة — $count سؤال، $points درجة';
  }

  @override
  String get assignToSections => 'تخصيص للفصول';

  @override
  String get noSectionsAssigned => 'لم يتم تعيينك لأي فصل بعد. اطلب من المدير.';

  @override
  String get assignToStudents => '…أو لطلاب بعينهم';

  @override
  String get noDueDate => 'بدون موعد تسليم — اضغط للتحديد';

  @override
  String dueOn(String date) {
    return 'التسليم $date';
  }

  @override
  String get published => 'منشور';

  @override
  String get publishedHint => 'عند الإيقاف يبقى مسودة تراها أنت فقط.';

  @override
  String get notAssignedWarning => 'لم يُخصص لأحد بعد — لن يراه أي طالب.';

  @override
  String allowedTypes(String types) {
    return 'المسموح: $types';
  }

  @override
  String get browse => 'استعراض';

  @override
  String get replace => 'استبدال';

  @override
  String uploadingPercent(String percent) {
    return 'جارٍ الرفع… $percent%';
  }

  @override
  String get deleteAssessmentBody =>
      'لن يراه الطلاب بعد الآن. النتائج المسلّمة تبقى في الدرجات.';

  @override
  String get deleteContentBody => 'لن يراه الطلاب، وسيُحذف الملف المرفوع.';

  @override
  String get contentAdminSub => 'كل ما نشره جميع المعلمين.';

  @override
  String get contentTeacherSub =>
      'ارفع الدروس وأنشئ الامتحانات ثم خصصها لفصل أو لطلاب بعينهم.';

  @override
  String get addContent => 'إضافة محتوى';

  @override
  String get noContentPermission => 'لم يمنحك المدير صلاحية نشر المحتوى بعد.';

  @override
  String get noContentSub =>
      'استخدم \"إضافة محتوى\" لرفع أول درس أو إنشاء اختبار.';

  @override
  String get notAssigned => 'غير مخصص';

  @override
  String get draft => 'مسودة';

  @override
  String questionsShort(String count, String time) {
    return '$count سؤال · $time';
  }

  @override
  String get untimed => 'بدون وقت';

  @override
  String minutesShort(String n) {
    return '$n دقيقة';
  }

  @override
  String get open => 'فتح';

  @override
  String get attendanceSaved => 'تم حفظ الحضور';

  @override
  String get attendanceSub => 'اختر الفصل واليوم وحدد حالة كل طالب ثم احفظ.';

  @override
  String get noStudentsInSection => 'لا يوجد طلاب في هذا الفصل';

  @override
  String get noStudentsInSectionSub =>
      'يضيف المدير الطلاب إلى الفصول من صفحة الطلاب.';

  @override
  String unmarkedCount(String count) {
    return '$count بدون تسجيل';
  }

  @override
  String get markAllPresent => 'تسجيل الكل حاضر';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get notSavedYet => 'لم يُحفظ بعد';

  @override
  String get gradesSub =>
      'تصل النتائج هنا فور تسليم الطالب. عدّل الدرجة أو أضف ملاحظة في أي وقت.';

  @override
  String get noAssessments => 'لا توجد امتحانات أو اختبارات بعد';

  @override
  String get noAssessmentsSub => 'أنشئ واحدًا من صفحة المحتوى.';

  @override
  String pointsTotal(String points) {
    return '$points درجة';
  }

  @override
  String get submitted => 'سلّموا';

  @override
  String get missing => 'لم يسلّموا';

  @override
  String get average => 'المتوسط';

  @override
  String get notSubmittedYet => 'لم يسلّموا بعد';

  @override
  String get gradedByTeacher => 'صحّحه المعلم';

  @override
  String get autoMarked => 'تصحيح تلقائي';

  @override
  String get enterGrade => 'إدخال الدرجة';

  @override
  String get editGrade => 'تعديل الدرجة';

  @override
  String scoreRange(String max) {
    return 'أدخل درجة من 0 إلى $max.';
  }

  @override
  String get score => 'الدرجة';

  @override
  String get feedback => 'ملاحظات';

  @override
  String get feedbackHint => 'تظهر للطالب ولأولياء أمره.';

  @override
  String get aboutAssignment => 'بخصوص واجب';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get noMessagesYetSub => 'ابدأ المحادثة — تصل الرسائل فورًا.';

  @override
  String aboutTitle(String title) {
    return 'بخصوص: $title';
  }

  @override
  String get typeMessage => 'اكتب رسالة…';

  @override
  String aboutChild(String name) {
    return 'بخصوص $name';
  }

  @override
  String get you => 'أنت';

  @override
  String get messagesTeacherSub => 'محادثات مع أولياء الأمور، محادثة لكل طالب.';

  @override
  String get noConversations => 'لا توجد محادثات بعد';

  @override
  String get noConversationsTeacherSub =>
      'يمكن لأولياء الأمور مراسلتك من تطبيقهم، أو ابدأ محادثة من صفحة طلابي.';

  @override
  String parentOf(String name) {
    return 'ولي أمر $name';
  }

  @override
  String get myStudentsSub =>
      'الطلاب في الفصول التي تدرّسها. اضغط على أحدهم لعرض النتائج والحضور وأولياء الأمور.';

  @override
  String get noParentsLinked =>
      'لا يوجد ولي أمر مرتبط بعد. يربطهم المدير من صفحة أولياء الأمور.';

  @override
  String get message => 'مراسلة';

  @override
  String get noAttendanceYet => 'لم يُسجّل حضور بعد.';

  @override
  String attendanceRate(String percent) {
    return 'الحضور $percent%';
  }

  @override
  String get results => 'النتائج';

  @override
  String get noResultsYet => 'لا توجد نتائج بعد.';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get haptics => 'الاهتزاز عند اللمس';

  @override
  String get branding => 'ألوان الهوية';

  @override
  String get resetColors => 'استعادة الألوان الافتراضية';

  @override
  String get brandingLocalHint => 'تُحفظ على هذا الجهاز.';

  @override
  String get developer => 'المطوّر';

  @override
  String get clearDeviceOverride => 'إلغاء معاينة الجهاز';

  @override
  String get clearDeviceOverrideSub => 'يوقف محاكاة نوع الجهاز ويسجّل الخروج.';

  @override
  String get account => 'الحساب';

  @override
  String get overdue => 'متأخر';

  @override
  String get startNow => 'ابدأ';

  @override
  String questionsCount(String count) {
    return '$count سؤال';
  }

  @override
  String get openExternally => 'فتح في تطبيق آخر';

  @override
  String get videoFailed => 'تعذّر تشغيل الفيديو. جرّب فتحه في تطبيق آخر.';

  @override
  String pageOf(String page, String pages) {
    return 'صفحة $page من $pages';
  }

  @override
  String get pdfFailed => 'تعذّر فتح الملف هنا. اضغط لفتحه في تطبيق آخر.';

  @override
  String get pinchToZoom => 'قرّب بإصبعين للتكبير';

  @override
  String get questions => 'الأسئلة';

  @override
  String notTakenYet(String name) {
    return 'لم يؤدِّ $name هذا بعد.';
  }

  @override
  String get examRules =>
      'أجب عن كل الأسئلة ثم سلّم. يمكنك التنقل بين الأسئلة بحرية. يمكنك التسليم مرة واحدة فقط.';

  @override
  String startExam(String type) {
    return 'ابدأ $type';
  }

  @override
  String get submitQuestion => 'تسليم إجاباتك؟';

  @override
  String submitWithBlanks(String count) {
    return 'ما زال $count سؤال بدون إجابة. لا يمكنك تعديل الإجابات بعد التسليم.';
  }

  @override
  String get submitBody => 'لا يمكنك تعديل الإجابات بعد التسليم.';

  @override
  String get submit => 'تسليم';

  @override
  String get keepGoing => 'متابعة';

  @override
  String get submitFailed => 'تعذّر التسليم';

  @override
  String get alreadySubmitted => 'لقد سلّمت هذا من قبل.';

  @override
  String get leaveExamQuestion => 'الخروج دون تسليم؟';

  @override
  String get leaveExamBody => 'ستفقد إجاباتك.';

  @override
  String get leave => 'خروج';

  @override
  String questionNofM(String n, String m) {
    return 'سؤال $n من $m';
  }

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get timeUp => 'انتهى الوقت — تم تسليم إجاباتك تلقائيًا.';

  @override
  String get submittedTitle => 'تم التسليم!';

  @override
  String get review => 'المراجعة';

  @override
  String get verdictExcellent => 'عمل ممتاز!';

  @override
  String get verdictGood => 'أحسنت!';

  @override
  String get verdictPass => 'ناجح';

  @override
  String get verdictKeepTrying => 'استمر في التدريب';

  @override
  String get home => 'الرئيسية';

  @override
  String get libraryTab => 'المكتبة';

  @override
  String get profile => 'حسابي';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get nothingAssignedYet => 'لا يوجد شيء مخصص لك بعد';

  @override
  String get nothingAssignedYetSub =>
      'عندما يشارك معلموك الدروس أو الامتحانات ستظهر هنا.';

  @override
  String get continueLearning => 'تابع التعلم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get upNext => 'التالي';

  @override
  String get newThisWeek => 'جديد';

  @override
  String get toDo => 'مطلوب';

  @override
  String get searchLessons => 'ابحث في الدروس والامتحانات والمعلمين…';

  @override
  String get nothingHere => 'لا يوجد شيء هنا';

  @override
  String get nothingHereSub => 'جرّب فلترًا أو بحثًا آخر.';

  @override
  String get averageGrade => 'متوسط الدرجات';

  @override
  String resultsCountLabel(String count) {
    return '$count نتيجة';
  }

  @override
  String daysRecorded(String count) {
    return '$count يوم مسجل';
  }

  @override
  String get lastDays => 'آخر الأيام';

  @override
  String get absencesAndLate => 'أيام الغياب والتأخير';

  @override
  String get myProgress => 'تقدّمي';

  @override
  String get noChildrenLinked => 'لا يوجد أبناء مرتبطون بعد';

  @override
  String get noChildrenLinkedSub => 'اطلب من المركز ربط أبنائك بحسابك.';

  @override
  String get yourChildren => 'أبناؤك';

  @override
  String get messageATeacher => 'مراسلة معلم';

  @override
  String get assignments => 'الواجبات';

  @override
  String get chooseTeacher => 'اختر المعلم';

  @override
  String get noTeachersToMessage =>
      'لا يوجد معلم لهذا الفصل يمكنه استقبال الرسائل بعد.';

  @override
  String get whichChild => 'بخصوص أي من أبنائك؟';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get noConversationsParentSub =>
      'اضغط \"رسالة جديدة\" لمراسلة أحد معلمي ابنك.';

  @override
  String get dashboard => 'لوحة المعلومات';

  @override
  String get dashboardAdminSub => 'الحضور والنتائج والمحتوى في المركز كله.';

  @override
  String get dashboardTeacherSub => 'الحضور والنتائج للفصول التي تدرّسها.';

  @override
  String get attendanceRateLabel => 'نسبة الحضور';

  @override
  String get averageScoreLabel => 'متوسط الدرجات';

  @override
  String get gradedResultsLabel => 'النتائج المصححة';

  @override
  String get publishedContentLabel => 'المحتوى المنشور';

  @override
  String get attendanceByStatus => 'الحضور حسب الحالة';

  @override
  String get attendanceByDay => 'الحضور حسب اليوم';

  @override
  String get averageBySection => 'متوسط الدرجات حسب الفصل';

  @override
  String get scoreBands => 'شرائح الدرجات';

  @override
  String get resultsByType => 'النتائج حسب النوع';

  @override
  String get band0 => 'أقل من ٥٠';

  @override
  String get band50 => '٥٠–٦٤';

  @override
  String get band65 => '٦٥–٧٩';

  @override
  String get band80 => '٨٠–١٠٠';

  @override
  String get charts => 'الرسوم';

  @override
  String get filters => 'التصفية';

  @override
  String get clear => 'مسح';

  @override
  String get apply => 'تطبيق';

  @override
  String get periodLabel => 'الفترة';

  @override
  String get period30 => 'آخر ٣٠ يومًا';

  @override
  String get period90 => 'آخر ٩٠ يومًا';

  @override
  String get periodAll => 'كل الفترات';

  @override
  String get onlyBelowPass => 'النتائج أقل من ٥٠٪ فقط';

  @override
  String get onlyAbsences => 'الغياب والتأخير فقط';

  @override
  String get exportTitle => 'تصدير';

  @override
  String get exportFileName => 'اسم الملف';

  @override
  String exportSaved(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get exportFailedTitle => 'تعذّر التصدير';

  @override
  String get exportCancelled => 'تم إلغاء التصدير.';

  @override
  String get student => 'الطالب';

  @override
  String get assessment => 'التقييم';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String rowsShown(String shown, String total) {
    return '$shown من $total';
  }

  @override
  String get nothingToChart => 'لا توجد بيانات للعرض بعد';

  @override
  String get nothingToChartSub =>
      'تمتلئ الرسوم تدريجيًا مع رصد الحضور وتصحيح التقييمات.';

  @override
  String get noRowsMatch => 'لا شيء يطابق هذه التصفية.';

  @override
  String get dashboardSearchHint => 'ابحث عن طالب أو تقييم';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get enterFileName => 'أدخل اسم الملف';

  @override
  String get focusOverdue => 'متأخر — أنهِه أولًا';

  @override
  String get focusNext => 'مهمتك التالية';

  @override
  String get focusNew => 'جديد لك';

  @override
  String get allCaughtUp => 'أنجزت كل شيء';

  @override
  String get allCaughtUpSub =>
      'لا توجد اختبارات بانتظارك. وقت مناسب لمراجعة درس.';

  @override
  String get dueToday => 'مستحق اليوم';

  @override
  String get dueTomorrow => 'مستحق غدًا';

  @override
  String dueInDays(String n) {
    return 'مستحق خلال $n أيام';
  }

  @override
  String overdueByDays(String n) {
    return 'متأخر $n أيام';
  }

  @override
  String get todayLabel => 'اليوم';

  @override
  String get notRecordedToday => 'لم يُسجَّل بعد';

  @override
  String get dayStreak => 'أيام متتالية';

  @override
  String get latestResult => 'آخر نتيجة';

  @override
  String aboveAverage(String n) {
    return 'أعلى من متوسطك بـ $n نقاط';
  }

  @override
  String belowAverage(String n) {
    return 'أقل من متوسطك بـ $n نقاط';
  }

  @override
  String get onYourAverage => 'مطابق لمتوسطك';

  @override
  String assessmentsDone(String done, String total) {
    return 'أنجزت $done من $total اختبارات';
  }

  @override
  String get atAGlance => 'نظرة سريعة';

  @override
  String get noResultYetShort => 'ستظهر نتيجتك الأولى هنا.';
}
