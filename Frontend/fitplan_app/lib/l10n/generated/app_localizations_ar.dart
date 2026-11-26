// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get errUsernameAlreadyExists => 'اسم المستخدم مأخوذ.';

  @override
  String get errInvalidCredentials =>
      'الإيميل أو اسم المستخدم أو كلمة المرور غلط.';

  @override
  String get errAccountDisabled =>
      'هذا الحساب موقوف. تواصل معنا على support@fitplan-app.com';

  @override
  String get errInvalidRefreshToken => 'انتهت جلستك. سجّل دخولك مرة ثانية.';

  @override
  String get errWrongPassword => 'كلمة المرور غلط.';

  @override
  String get errUserNotFound => 'ما لقينا الحساب.';

  @override
  String get errInvalidFile => 'الملف ما ينفع. نقبل صور JPG و PNG بس.';

  @override
  String get errPictureNotFound => 'ما عندك صورة شخصية.';

  @override
  String get errFileTooLarge => 'الملف أكبر من 5 ميقا.';

  @override
  String get errExerciseNotFound => 'ما لقينا التمرين.';

  @override
  String get errWorkoutPlanNotFound => 'ما لقينا الجدول.';

  @override
  String get errExerciseAlreadyExists => 'التمرين موجود في الجدول من قبل.';

  @override
  String get errWorkoutPlanExerciseNotFound => 'ما لقينا التمرين في الجدول.';

  @override
  String get errWorkoutSessionNotFound => 'ما لقينا الحصة.';

  @override
  String get errNoActiveSession => 'ما عندك حصة شغّالة الحين.';

  @override
  String get errActiveSessionExists => 'عندك حصة شغّالة من قبل.';

  @override
  String get errSessionNotActive => 'الحصة خلصت وما تقدر تعدّل عليها.';

  @override
  String get errEmptySession =>
      'سجّل جولة وحدة أو كارديو على الأقل قبل ما تخلّص، أو ألغِ الحصة.';

  @override
  String get errSessionExerciseNotFound => 'ما لقينا التمرين في الحصة.';

  @override
  String get errExerciseAlreadyInSession => 'التمرين موجود في الحصة من قبل.';

  @override
  String get errSetLimitReached => 'أقصى حد 10 جولات للتمرين في الحصة الوحدة.';

  @override
  String get errSessionSetNotFound => 'ما لقينا الجولة.';

  @override
  String get errCardioEntryNotFound => 'ما لقينا الكارديو.';

  @override
  String get errCardioMachineRetired =>
      'خيار \"غيره\" ما عاد موجود. اختر الجهاز، أو السباحة.';

  @override
  String get errCardioDistanceTooLong => 'أقصى مسافة 50,000 متر.';

  @override
  String get errSessionNotCompleted => 'الحصة لسا شغّالة.';

  @override
  String get errNoExerciseHistory => 'ما سويت هالتمرين في حصة مخلّصة للحين.';

  @override
  String get errBodyWeightEntryNotFound => 'ما لقينا الوزن.';

  @override
  String get errTooManyRequests => 'حاولت كثير. انتظر دقيقة وجرّب مرة ثانية.';

  @override
  String get errValidation => 'تأكد من اللي كتبته وجرّب مرة ثانية.';

  @override
  String get errTimeout => 'السيرفر طوّل في الرد. جرّب بعد شوي.';

  @override
  String get errNetwork =>
      'ما قدرنا نوصل للسيرفر. تأكد من النت وجرّب مرة ثانية.';

  @override
  String get errServerStarting => 'السيرفر يشتغل الحين. جرّب بعد شوي.';

  @override
  String get errSomethingWrong => 'صار خطأ.';

  @override
  String get errGeneric => 'صار خطأ. جرّب مرة ثانية.';

  @override
  String get tryAgain => 'جرّب مرة ثانية';

  @override
  String amountKg(String amount) {
    return '$amount كيلو';
  }

  @override
  String volumeThousandsKg(String amount) {
    return '$amount ألف كيلو';
  }

  @override
  String volumeThousands(String amount) {
    return '$amount ألف';
  }

  @override
  String repsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عدّة',
      few: '$count عدّات',
      two: 'عدّتين',
      one: 'عدّة وحدة',
    );
    return '$_temp0';
  }

  @override
  String setWeightReps(String kg, int reps) {
    return '$kg كيلو × $reps';
  }

  @override
  String get durationUnderMinute => 'أقل من 1 د';

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String durationHours(int hours) {
    return '$hours س';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'قبل $days يوم',
      few: 'قبل $days أيام',
      two: 'قبل يومين',
    );
    return '$_temp0';
  }

  @override
  String get kg => 'كيلو';

  @override
  String get authWrongLogin => 'الإيميل أو اسم المستخدم أو كلمة المرور غلط.';

  @override
  String get authUsernameTaken => 'اسم المستخدم مأخوذ. جرّب اسم ثاني.';

  @override
  String get loginTitle => 'هلا والله، نوّرت!';

  @override
  String get loginSubtitle => 'اشتقنا لك! سجّل دخولك وكمّل من وين وقفت.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get enterUsername => 'اكتب اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'اكتب كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get logIn => 'ادخل';

  @override
  String get newToFitPlan => 'أول مرة معنا؟';

  @override
  String get createAnAccount => 'حيّاك، سجّل الحين';

  @override
  String get copyCode => 'انسخ الرمز';

  @override
  String get savedIt => 'حفظته';

  @override
  String atLeastChars(int count) {
    return 'على الأقل $count حروف';
  }

  @override
  String atMostChars(int count) {
    return '$count حرف كحد أقصى';
  }

  @override
  String get registerTitle => 'حيّاك الله في FitPlan';

  @override
  String get registerSubtitle =>
      'رتّب تمارينك، سجّل كل جولة، وشوف قوتك تزيد يوم بعد يوم.';

  @override
  String get confirmPassword => 'أكّد كلمة المرور';

  @override
  String get passwordsDontMatch => 'كلمة المرور ما تتطابق';

  @override
  String passwordHint(int count) {
    return 'استخدم $count حروف على الأقل.';
  }

  @override
  String get createAccount => 'يلا نبدأ';

  @override
  String get haveAccount => 'عندك حساب من قبل؟';

  @override
  String get resetTitle => 'ولا يهمك، نرجّعك لحسابك';

  @override
  String get resetSubtitle =>
      'اكتب إيميل حسابك، وبنرسل لك رمز تختار فيه كلمة مرور جديدة.';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordLengthRange => 'استخدم من 8 إلى 100 حرف';

  @override
  String get confirmNewPassword => 'أكّد كلمة المرور الجديدة';

  @override
  String get thePasswordsDontMatch => 'كلمة المرور ما تتطابق';

  @override
  String get resetPassword => 'غيّر كلمة المرور';

  @override
  String get rememberedIt => 'تذكّرتها؟';

  @override
  String get showPassword => 'اعرض كلمة المرور';

  @override
  String get hidePassword => 'اخفِ كلمة المرور';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabPlans => 'جداولي';

  @override
  String get tabHistory => 'السجل';

  @override
  String get tabProgress => 'تقدّمك';

  @override
  String decrease(String label) {
    return 'نقّص $label';
  }

  @override
  String increase(String label) {
    return 'زوّد $label';
  }

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تمرين',
      few: '$count تمارين',
      two: 'تمرينين',
      one: 'تمرين واحد',
    );
    return '$_temp0';
  }

  @override
  String workoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      few: '$count حصص',
      two: 'حصتين',
      one: 'حصة وحدة',
    );
    return '$_temp0';
  }

  @override
  String setCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولة',
      few: '$count جولات',
      two: 'جولتين',
      one: 'جولة وحدة',
    );
    return '$_temp0';
  }

  @override
  String get addToWhichPlan => 'تضيفه لأي جدول؟';

  @override
  String get newPlan => 'جدول جديد';

  @override
  String get newPlanSubtitle => 'سوّي جدول جديد وحطه فيه';

  @override
  String get couldNotLoadPlans => 'ما قدرنا نجيب جداولك.';

  @override
  String get noPlansYetShort => 'ما عندك جداول للحين.';

  @override
  String get alreadyInPlan => 'موجود في هالجدول';

  @override
  String get deletePlanTitle => 'تحذف الجدول؟';

  @override
  String deletePlanBody(String name) {
    return 'بنحذف \"$name\". حصصك اللي فاتت تبقى في السجل.';
  }

  @override
  String get keep => 'خلّيه';

  @override
  String get delete => 'حذف';

  @override
  String get plan => 'جدول';

  @override
  String get planOptions => 'خيارات الجدول';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get deletePlan => 'حذف الجدول';

  @override
  String get couldNotLoadPlan => 'ما قدرنا نجيب الجدول.';

  @override
  String get addFirstExercise => 'ضيف أول تمرين';

  @override
  String get addFirstExerciseBody =>
      'اختر من 1,500 تمرين، وحدد كم جولة وكم عدّة تبي.';

  @override
  String get addExercise => 'ضيف تمرين';

  @override
  String get add => 'ضيف';

  @override
  String get startWorkout => 'ابدأ الحصة';

  @override
  String get editPlan => 'عدّل الجدول';

  @override
  String get name => 'الاسم';

  @override
  String get planNameHint => 'يوم الدفع';

  @override
  String get planNameRequired => 'سمِّ الجدول';

  @override
  String get descriptionOptional => 'وصف (اختياري)';

  @override
  String get planDescriptionHint => 'صدر وأكتاف وتراي';

  @override
  String get createPlan => 'سوّي الجدول';

  @override
  String get save => 'حفظ';

  @override
  String get plansTitle => 'جداولي';

  @override
  String get browseExercises => 'تصفّح التمارين';

  @override
  String get plansSubtitle => 'جداولك. ابدأ واحد وسجّل وأنت تتمرن.';

  @override
  String get noPlansYet => 'ما عندك جداول';

  @override
  String get noPlansYetBody => 'سوّي جدول مثل \"يوم الدفع\" وحط فيه تمارينك.';

  @override
  String get createAPlan => 'سوّي جدول';

  @override
  String get quickWorkoutNoPlan => 'حصة سريعة بدون جدول';

  @override
  String get noExercisesYet => 'ما فيه تمارين للحين';

  @override
  String startPlan(String name) {
    return 'ابدأ $name';
  }

  @override
  String get targetSubtitle => 'هدفك في كل حصة';

  @override
  String get sets => 'الجولات';

  @override
  String get reps => 'العدّات';

  @override
  String get restBetweenSets => 'الراحة بين الجولات';

  @override
  String get addToPlan => 'ضيفه للجدول';

  @override
  String get removeFromPlan => 'شيله من الجدول';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'هلا';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String greeting(String greeting, String name) {
    return '$greeting يا $name';
  }

  @override
  String get readyToTrain => 'جاهز للتمرين؟';

  @override
  String get profile => 'حسابي';

  @override
  String get openProfile => 'افتح حسابي';

  @override
  String get inProgress => 'شغّالة الحين';

  @override
  String setsLoggedSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سجّلت $count جولة للحين',
      few: 'سجّلت $count جولات للحين',
      two: 'سجّلت جولتين للحين',
      one: 'سجّلت جولة وحدة للحين',
      zero: 'ما سجّلت ولا جولة للحين',
    );
    return '$_temp0';
  }

  @override
  String get resumeWorkout => 'كمّل حصتك';

  @override
  String get upNext => 'تمرين اليوم';

  @override
  String get chooseAnotherPlan => 'اختر جدول ثاني';

  @override
  String get getStarted => 'يلا نبدأ';

  @override
  String get makeFirstPlan => 'سوّي أول جدول لك';

  @override
  String get makeFirstPlanBody =>
      'اختر تمارينك مرة وحدة، وبعدها ابدأ بضغطة كل ما تتمرن.';

  @override
  String get goToPlans => 'روح للجداول';

  @override
  String get quickWorkout => 'حصة سريعة';

  @override
  String get thisWeek => 'هالأسبوع';

  @override
  String weekGoalMet(int count) {
    return '$count حصص · حققت هدفك';
  }

  @override
  String weekOfGoal(int count, int goal) {
    return '$count من $goal حصص';
  }

  @override
  String get noWorkoutsYet => 'ما فيه حصص للحين';

  @override
  String trainedDaysSemantics(int days) {
    return 'تمرنت $days من 7 أيام هالأسبوع';
  }

  @override
  String get lastSession => 'آخر حصة';

  @override
  String get bodyChest => 'صدر';

  @override
  String get bodyBack => 'ظهر';

  @override
  String get bodyShoulders => 'أكتاف';

  @override
  String get bodyUpperArms => 'باي وتراي';

  @override
  String get bodyLowerArms => 'سواعد';

  @override
  String get bodyUpperLegs => 'أرجل';

  @override
  String get bodyLowerLegs => 'بطات';

  @override
  String get bodyWaist => 'بطن';

  @override
  String get bodyNeck => 'رقبة';

  @override
  String get bodyCardio => 'كارديو';

  @override
  String get howToDoIt => 'طريقة التمرين';

  @override
  String get couldNotLoadInstructions => 'ما قدرنا نجيب الطريقة.';

  @override
  String get noInstructions => 'ما فيه شرح لهالتمرين للحين.';

  @override
  String get addToAPlan => 'ضيفه لجدول';

  @override
  String addedTo(String name) {
    return 'انضاف إلى $name';
  }

  @override
  String get open => 'افتح';

  @override
  String get exercises => 'التمارين';

  @override
  String get searchExercises => 'دوّر على تمرين';

  @override
  String get clear => 'امسح';

  @override
  String get all => 'الكل';

  @override
  String get couldNotLoadExercises => 'ما قدرنا نجيب التمارين.';

  @override
  String get noExercisesFound => 'ما لقينا تمارين';

  @override
  String get noExercisesFoundBody => 'جرّب كلمة ثانية أو عضلة ثانية.';

  @override
  String get loadMore => 'اعرض أكثر';

  @override
  String addExerciseToPlanTooltip(String name) {
    return 'ضيف $name لجدول';
  }

  @override
  String addExerciseTooltip(String name) {
    return 'ضيف $name';
  }

  @override
  String bodyPartAdded(String part) {
    return '$part · مضاف';
  }

  @override
  String howToDo(String name) {
    return 'طريقة $name';
  }

  @override
  String get alreadyAdded => 'مضاف من قبل';

  @override
  String get showHowToDoIt => 'وريني الطريقة';

  @override
  String get demoNotAvailableFull => 'ما فيه فيديو. امشِ على الخطوات تحت.';

  @override
  String get demoNotAvailable => 'ما فيه فيديو';

  @override
  String get followStepsBelow => 'امشِ على الخطوات تحت.';

  @override
  String get couldNotLoadHistory => 'ما قدرنا نجيب سجلك.';

  @override
  String get historyTitle => 'السجل';

  @override
  String get historySubtitle => 'كل حصة خلّصتها.';

  @override
  String get noHistoryBody => 'خلّص أول حصة وبتطلع لك هنا.';

  @override
  String get time => 'الوقت';

  @override
  String get volume => 'مجموع الأوزان';

  @override
  String get kcal => 'سعرة';

  @override
  String get cardio => 'كارديو';

  @override
  String get deleteWorkoutTitle => 'تحذف الحصة؟';

  @override
  String deleteWorkoutBody(String name) {
    return 'بنحذف \"$name\" وكل جولاتها. وما تقدر ترجعها.';
  }

  @override
  String get workout => 'حصة';

  @override
  String get workoutOptions => 'خيارات الحصة';

  @override
  String get deleteWorkout => 'حذف الحصة';

  @override
  String get couldNotLoadWorkout => 'ما قدرنا نجيب الحصة.';

  @override
  String topSet(String kg) {
    return 'أعلى جولة $kg كيلو';
  }

  @override
  String get bodyweight => 'وزن جسمك';

  @override
  String kcalAmount(int amount) {
    return '≈ $amount سعرة';
  }

  @override
  String get couldNotLoadProfile => 'ما قدرنا نجيب حسابك.';

  @override
  String get logOut => 'تسجيل خروج';

  @override
  String get chooseFromGallery => 'اختر من الصور';

  @override
  String get takePhoto => 'صوّر';

  @override
  String get removePhoto => 'شيل الصورة';

  @override
  String get changeProfilePhoto => 'غيّر صورتك';

  @override
  String get viewProfilePhoto => 'شوف صورتك';

  @override
  String memberSince(String date) {
    return 'معنا من $date';
  }

  @override
  String get addPhoto => 'ضيف صورة';

  @override
  String get changePhoto => 'غيّر الصورة';

  @override
  String get close => 'سكّر';

  @override
  String get profilePhoto => 'صورتك';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteAccountTitle => 'تحذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'بنحذف جداولك وحصصك وأوزانك وصورتك نهائيًا، وما تقدر ترجعها. اكتب كلمة المرور عشان تأكد.';

  @override
  String get accountDeleted => 'انحذف حسابك.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get exerciseDataCredit => 'بيانات التمارين: AscendAPI';

  @override
  String get bodyWeight => 'وزن جسمك';

  @override
  String get addWeightHint => 'حط وزنك عشان نحسب لك السعرات اللي تحرقها.';

  @override
  String get update => 'حدّث';

  @override
  String get enterNumber => 'اكتب رقم، مثل 78.5';

  @override
  String weightRange(int min, int max) {
    return 'بين $min و$max كيلو';
  }

  @override
  String get todaysWeight => 'وزنك اليوم';

  @override
  String get weightTrendNote => 'نحفظ كل وزن تسجله، عشان تتابع تغيّرك.';

  @override
  String get weight => 'الوزن';

  @override
  String get bioSaved => 'حفظنا النبذة';

  @override
  String get bio => 'نبذة عنك';

  @override
  String get bioHint => 'أهدافك، تمرينك المفضل، أي شيء…';

  @override
  String get saveBio => 'احفظ النبذة';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'تلقائي';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String tonnes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'طن',
    );
    return '$_temp0';
  }

  @override
  String get msPiano => 'بيانو كبير';

  @override
  String get msPianoPlural => 'بيانوهات كبيرة';

  @override
  String get msCar => 'سيارة صغيرة';

  @override
  String get msCarPlural => 'سيارات صغيرة';

  @override
  String get msElephant => 'فيل';

  @override
  String get msElephantPlural => 'أفيال';

  @override
  String get msBus => 'باص';

  @override
  String get msBusPlural => 'باصات';

  @override
  String get msTruck => 'شاحنة محمّلة';

  @override
  String get msTruckPlural => 'شاحنات محمّلة';

  @override
  String get msWhale => 'حوت أزرق';

  @override
  String get msWhalePlural => 'حيتان زرقاء';

  @override
  String get msJet => 'طيارة';

  @override
  String get msJetPlural => 'طيارات';

  @override
  String aboutOne(String name) {
    return 'تقريبًا وزن $name';
  }

  @override
  String aboutMany(String count, String name) {
    return 'تقريبًا وزن $count $name';
  }

  @override
  String get couldNotLoadProgress => 'ما قدرنا نجيب تقدّمك.';

  @override
  String get progressTitle => 'تقدّمك';

  @override
  String get progressSubtitle => 'وش جمعت من تمرينك.';

  @override
  String get streakNoGoal =>
      'الأسبوع ينحسب إذا تمرنت مرة على الأقل. حط لك هدف وارفع السقف.';

  @override
  String streakGoalReached(int done, int goal) {
    return '$done حصص هالأسبوع، وحققت هدفك ($goal). كفو.';
  }

  @override
  String streakToGo(int done, int goal, int left) {
    return '$done من $goal هالأسبوع، باقي لك $left.';
  }

  @override
  String get noStreakYet => 'ما عندك سلسلة للحين';

  @override
  String weekStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسبوع ورا بعض',
      few: '$count أسابيع ورا بعض',
      two: 'أسبوعين ورا بعض',
      one: 'أول أسبوع في سلسلتك',
    );
    return '$_temp0';
  }

  @override
  String get setGoal => 'حط هدف';

  @override
  String get aWeek => 'بالأسبوع';

  @override
  String get vsLastWeek => '▲ مقارنة بالأسبوع اللي فات';

  @override
  String get workouts => 'الحصص';

  @override
  String get kgLifted => 'الأوزان';

  @override
  String minutesShort(int minutes) {
    return '$minutes د';
  }

  @override
  String get same => 'نفسه';

  @override
  String get strength => 'القوة';

  @override
  String get body => 'الجسم';

  @override
  String get chooseExercise => 'اختر تمرين';

  @override
  String get strengthEmpty => 'خلّص حصة وبيطلع لك تطور قوتك هنا.';

  @override
  String fromLastWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'من آخر $count حصة',
      few: 'من آخر $count حصص',
      two: 'من آخر حصتين',
      one: 'من آخر حصة',
    );
    return '$_temp0';
  }

  @override
  String latestBest(String kg, String set) {
    return 'آخر حصة · أفضل رقم $kg كيلو من $set';
  }

  @override
  String get estimated1rm => 'أقصى رفعة متوقعة';

  @override
  String get topSetLabel => 'أعلى جولة';

  @override
  String get bestReps => 'أكثر عدّات';

  @override
  String get repsUnit => 'عدّة';

  @override
  String get logWeightTrend => 'سجّل وزنك عشان تشوف تغيّره.';

  @override
  String get logWeight => 'سجّل وزنك';

  @override
  String latestWeighIn(String when) {
    return 'آخر وزن، $when';
  }

  @override
  String get recentRecords => 'آخر أرقامك القياسية';

  @override
  String get weeklyVolume => 'مجموع الأوزان كل أسبوع';

  @override
  String get kgLiftedLower => 'كيلو';

  @override
  String get weighIns => 'أوزانك';

  @override
  String get logTodaysWeight => 'سجّل وزنك اليوم';

  @override
  String recordsMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      few: '$count حصص',
      two: 'حصتين',
      one: 'حصة وحدة',
    );
    return '$_temp0 · آخر مرة $when';
  }

  @override
  String get recordHeaviest => 'أثقل وزن';

  @override
  String get recordEstimated1rm => 'أقصى رفعة متوقعة';

  @override
  String get recordMostReps => 'أكثر عدّات';

  @override
  String get recordBestSetVolume => 'أعلى مجموع أوزان في جولة';

  @override
  String get finishWithWeights => 'خلّص حصة فيها أوزان وتبدأ';

  @override
  String get keepGoing => 'كمّل';

  @override
  String get lifetimeVolume => 'مجموع الأوزان اللي شلتها';

  @override
  String nextMilestone(String name) {
    return 'اللي بعده: $name';
  }

  @override
  String toGo(String amount) {
    return 'باقي $amount';
  }

  @override
  String get allMilestones => 'خلّصت كل الإنجازات. أسطورة.';

  @override
  String get milestones => 'الإنجازات';

  @override
  String liftedSoFar(String amount) {
    return 'مجموع الأوزان للحين: $amount';
  }

  @override
  String get milestonesNote =>
      'الأوزان تقريبية. مجموع الأوزان = العدّات × الوزن، من الحصص المخلّصة. جولات وزن الجسم والكارديو ما تنحسب.';

  @override
  String reachedOn(String date) {
    return 'وصلته $date';
  }

  @override
  String get weeklyGoal => 'هدفك الأسبوعي';

  @override
  String get weeklyGoalBody => 'كم حصة بالأسبوع. حققه وتطول سلسلتك.';

  @override
  String get noGoal => 'بدون هدف';

  @override
  String goalPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة بالأسبوع',
      few: '$count حصص بالأسبوع',
      two: 'حصتين بالأسبوع',
      one: 'حصة وحدة بالأسبوع',
    );
    return '$_temp0';
  }

  @override
  String firstTimeWith(String name) {
    return 'أول مرة تسوي \"$name\". المرة الجاية بتشوف الفرق.';
  }

  @override
  String personalRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رقم قياسي',
      few: '$count أرقام قياسية',
      two: 'رقمين قياسيين',
      one: 'رقم قياسي جديد',
    );
    return '$_temp0';
  }

  @override
  String volumeVsLast(String name) {
    return 'مجموع الأوزان مقارنة بآخر $name';
  }

  @override
  String lastTimeWas(String when) {
    return 'آخر مرة كانت $when';
  }

  @override
  String get todayLabel => 'اليوم';

  @override
  String get lastLabel => 'اللي فات';

  @override
  String setWeightRepsShort(String kg, int reps) {
    return '$kg × $reps';
  }

  @override
  String get nothingLoggedYet => 'ما سجّلت شيء للحين';

  @override
  String get oneMoreEntry => 'سجّل مرة ثانية ويبدأ الرسم هنا';

  @override
  String trendSemantics(String from, String to, String unit) {
    return 'التغيّر من $from إلى $to $unit';
  }

  @override
  String weekBarsSemantics(String now, String last) {
    return 'هالأسبوع $now، الأسبوع اللي فات $last';
  }

  @override
  String weekOf(String date) {
    return 'أسبوع $date';
  }

  @override
  String get thisWeekLabel => 'هالأسبوع';

  @override
  String get cfSpeed => 'السرعة';

  @override
  String get cfIncline => 'الميلان';

  @override
  String get cfDistance => 'المسافة';

  @override
  String get cfLevel => 'المستوى';

  @override
  String get cfDamper => 'المقاومة';

  @override
  String get cfFloors => 'الأدوار';

  @override
  String get cfCadence => 'سرعة الدوّاسة';

  @override
  String get cfStrokeRate => 'السحبات بالدقيقة';

  @override
  String get cfPoolLength => 'طول المسبح';

  @override
  String get cfLaps => 'اللفّات';

  @override
  String get unitKmh => 'كم/س';

  @override
  String get unitKm => 'كم';

  @override
  String get unitM => 'م';

  @override
  String cardioRange(String label, String min, String max, String unit) {
    return '$label: من $min إلى $max$unit';
  }

  @override
  String get cmTreadmill => 'سير';

  @override
  String get cmStairs => 'درج';

  @override
  String get cmBike => 'سيكل';

  @override
  String get cmElliptical => 'إليبتكال';

  @override
  String get cmRower => 'جهاز التجديف';

  @override
  String get cmSwimming => 'سباحة';

  @override
  String get cmOther => 'غيره';

  @override
  String get whyIncrease => 'جبت كل العدّات المرة اللي فاتت';

  @override
  String get whyRepeat => 'نفس الوزن، زِد العدّات';

  @override
  String get whyDeload => 'خفّف شوي عشان ترتاح بعد حصتين قويتين';

  @override
  String get whyMoreReps => 'عدّة زيادة على أفضل رقم لك';

  @override
  String cdSpeed(String value) {
    return '$value كم/س';
  }

  @override
  String cdIncline(String value) {
    return 'ميلان $value%';
  }

  @override
  String cdKm(String value) {
    return '$value كم';
  }

  @override
  String cdMeters(int value) {
    return '$value م';
  }

  @override
  String cdDamper(int value) {
    return 'مقاومة $value';
  }

  @override
  String cdLevel(int value) {
    return 'مستوى $value';
  }

  @override
  String cdFloors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دور',
      few: '$count أدوار',
      two: 'دورين',
      one: 'دور واحد',
    );
    return '$_temp0';
  }

  @override
  String cdLapsOf(int count, int pool) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لفّة في مسبح $pool م',
      few: '$count لفّات في مسبح $pool م',
      two: 'لفّتين في مسبح $pool م',
      one: 'لفّة وحدة في مسبح $pool م',
    );
    return '$_temp0';
  }

  @override
  String cdLaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لفّة',
      few: '$count لفّات',
      two: 'لفّتين',
      one: 'لفّة وحدة',
    );
    return '$_temp0';
  }

  @override
  String cdPool(int value) {
    return 'مسبح $value م';
  }

  @override
  String secondsShort(int seconds) {
    return '$seconds ث';
  }

  @override
  String get durationRange => 'المدة: من 1 إلى 300 دقيقة';

  @override
  String get addCardio => 'ضيف كارديو';

  @override
  String get howLong => 'كم المدة؟';

  @override
  String get minUnit => 'دقيقة';

  @override
  String get moreDetails => 'تفاصيل أكثر (اختياري)';

  @override
  String get swimDistanceNote =>
      'يكفي اللفّات وطول المسبح، والمسافة نحسبها لك.';

  @override
  String get caloriesRough => 'السعرات تقريبية.';

  @override
  String get caloriesRoughMachine =>
      'السعرات تقريبية، لأن كل جهاز يحسب المجهود بطريقته.';

  @override
  String get addWeightForCalories =>
      'حط وزنك في حسابي عشان تشوف السعرات اللي تحرقها.';

  @override
  String get finishWorkoutTitle => 'خلّصت الحصة؟';

  @override
  String get finishAllDone => 'كفو، سويت كل اللي خططت له.';

  @override
  String finishUnfinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $count تمرين ما كمّلتهم. تقدر تخلّص، واللي سجّلته محفوظ.',
      few: 'باقي $count تمارين ما كمّلتهم. تقدر تخلّص، واللي سجّلته محفوظ.',
      two: 'باقي تمرينين ما كمّلتهم. تقدر تخلّص، واللي سجّلته محفوظ.',
      one: 'باقي تمرين ما كمّلته. تقدر تخلّص، واللي سجّلته محفوظ.',
    );
    return '$_temp0';
  }

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get howDidItFeel => 'وش حسّيت؟';

  @override
  String get finishWorkout => 'خلّصت الحصة';

  @override
  String get keepTraining => 'كمّل تمرين';

  @override
  String addedToPlan(String what, String name) {
    return 'انضاف $what إلى $name';
  }

  @override
  String addToPlanQuestion(String name) {
    return 'تضيفهم إلى $name؟';
  }

  @override
  String get planAdditionsBody =>
      'ضفت هذي التمارين في الحصة. اختر وش تبي تخليه في جدولك.';

  @override
  String addCountToPlan(int count) {
    return 'ضيف $count للجدول';
  }

  @override
  String get notNow => 'مو الحين';

  @override
  String addName(String name) {
    return 'ضيف $name';
  }

  @override
  String targetForSemantics(String name, String target) {
    return 'الهدف لـ $name: $target. اضغط عشان تغيّره.';
  }

  @override
  String get discardWorkoutTitle => 'تلغي الحصة؟';

  @override
  String get discardWorkoutBody => 'كل اللي سجّلته في الحصة بينحذف.';

  @override
  String get keepGoingButton => 'كمّل تمرينك';

  @override
  String get discard => 'إلغاء';

  @override
  String get noCardioToday => 'ما فيه كارديو اليوم؟';

  @override
  String get cardioReminderBody =>
      'كم دقيقة كارديو حلوة تختم فيها. والقرار لك.';

  @override
  String get finishWithoutCardio => 'خلّص بدون كارديو';

  @override
  String get logSomethingFirst =>
      'سجّل جولة أو كارديو على الأقل، أو ألغِ الحصة.';

  @override
  String get couldNotLoadSession => 'ما قدرنا نجيب حصتك.';

  @override
  String get noWorkoutInProgress => 'ما فيه حصة شغّالة';

  @override
  String get noWorkoutInProgressBody => 'ابدأ وحدة من جدول، أو حصة سريعة.';

  @override
  String get back => 'رجوع';

  @override
  String get minimise => 'صغّر';

  @override
  String get discardWorkout => 'إلغاء الحصة';

  @override
  String get finish => 'خلّصت';

  @override
  String doneOfTotal(int done, int total) {
    return 'خلّصت $done من $total';
  }

  @override
  String get quickWorkoutOverline => 'حصة سريعة';

  @override
  String get whatTraining => 'وش بتتمرن اليوم؟';

  @override
  String get quickWorkoutBody => 'ضيف التمارين وأنت ماشي، أو سجّل كارديو بس.';

  @override
  String setsLoggedOfTarget(int logged, int target) {
    return '$logged / $target جولات';
  }

  @override
  String exerciseRowSemantics(
    int number,
    String name,
    String progress,
    String done,
    String active,
  ) {
    return '$number. $name، $progress$done$active. اضغط عشان تفتحه.';
  }

  @override
  String get semDone => '، خلص';

  @override
  String get semDoThisNow => '، هذا الحين';

  @override
  String progressWithTarget(String progress, int sets, int reps) {
    return '$progress · الهدف $sets × $reps';
  }

  @override
  String get cardioFinishPrompt => 'تختم بكارديو؟ اختر الجهاز والمدة.';

  @override
  String get noKcal => '— سعرة';

  @override
  String get deleteCardio => 'حذف الكارديو';

  @override
  String get workoutInProgressTitle => 'عندك حصة شغّالة';

  @override
  String workoutInProgressBody(String name) {
    return 'حصة \"$name\" شغّالة. خلّصها أو ألغها قبل ما تبدأ وحدة جديدة.';
  }

  @override
  String get resume => 'كمّلها';

  @override
  String get duration => 'المدة';

  @override
  String get caloriesEstimated => 'السعرات (تقريبًا)';

  @override
  String get calories => 'السعرات';

  @override
  String get addWeightInProfile => 'حط وزنك في حسابي';

  @override
  String get workoutComplete => 'خلّصت الحصة';

  @override
  String thisWorkoutCompare(String comparison) {
    return 'حصة اليوم: $comparison';
  }

  @override
  String get done => 'تمام';

  @override
  String get newMilestone => 'إنجاز جديد';

  @override
  String youLifted(String name) {
    return 'شلت وزن $name!';
  }

  @override
  String totalPassed(String amount, String name) {
    return 'مجموع أوزانك عدّى $amount، يعني تقريبًا وزن $name';
  }

  @override
  String passedOnTheWay(String names) {
    return 'وعدّيت $names في طريقك';
  }

  @override
  String get and => ' و';

  @override
  String get removeExerciseTitle => 'تشيل التمرين؟';

  @override
  String removeExerciseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الـ $count جولة اللي سجّلتها في هالتمرين بتنحذف.',
      few: 'الـ $count جولات اللي سجّلتها في هالتمرين بتنحذف.',
      two: 'الجولتين اللي سجّلتها في هالتمرين بتنحذف.',
      one: 'الجولة اللي سجّلتها في هالتمرين بتنحذف.',
      zero: 'بنشيل التمرين من الحصة.',
    );
    return '$_temp0';
  }

  @override
  String get remove => 'إزالة';

  @override
  String targetSetsReps(int sets, int reps) {
    return 'الهدف $sets × $reps';
  }

  @override
  String closeName(String name) {
    return 'سكّر $name';
  }

  @override
  String get exerciseOptions => 'خيارات التمرين';

  @override
  String get removeFromWorkout => 'إزالة من الحصة';

  @override
  String get addSet => 'ضيف جولة';

  @override
  String get nextExercise => 'التمرين اللي بعده';

  @override
  String get now => 'الحين';

  @override
  String restChipSemantics(String time) {
    return 'راحة $time بين الجولات. اضغط عشان تغيّرها.';
  }

  @override
  String restChip(String time) {
    return 'راحة $time';
  }

  @override
  String suggestedToday(String target, String why) {
    return 'المقترح اليوم: $target، $why';
  }

  @override
  String get todayPrefix => 'اليوم  ';

  @override
  String get firstTimeExercise => 'أول مرة تسويه. اليوم يكون رقمك الأساسي.';

  @override
  String lastTimeWhen(String when) {
    return 'آخر مرة · $when';
  }

  @override
  String get bodyweightShort => 'وزن الجسم';

  @override
  String get weightHint => 'الوزن';

  @override
  String get restSheetBody =>
      'الراحة بعد كل جولة، لهالحصة بس. جدولك يبقى مثل ما هو.';

  @override
  String get restDone => 'خلصت الراحة';

  @override
  String get rest => 'راحة';

  @override
  String get go => 'يلا!';

  @override
  String get skip => 'تخطي';

  @override
  String setNumber(int number) {
    return 'الجولة $number';
  }

  @override
  String get weightKgLabel => 'الوزن (كيلو)';

  @override
  String get emptyIsBodyweight => 'فاضي = وزن جسمك';

  @override
  String get deleteSet => 'حذف الجولة';

  @override
  String repsRange(int max) {
    return 'العدّات: من 1 إلى $max';
  }

  @override
  String weightRangeSet(String max) {
    return 'الوزن: من 0 إلى $max كيلو';
  }

  @override
  String get colSet => 'جولة';

  @override
  String get colKg => 'كيلو';

  @override
  String get colReps => 'عدّات';

  @override
  String setDoneSemantics(int number, String weight, int reps) {
    return 'الجولة $number: $weight، $reps عدّة، خلصت. اضغط عشان تعدّل.';
  }

  @override
  String get semBodyweight => 'وزن الجسم';

  @override
  String semKilograms(String kg) {
    return '$kg كيلو';
  }

  @override
  String setWeightSemantics(int number) {
    return 'وزن الجولة $number بالكيلو';
  }

  @override
  String setRepsSemantics(int number) {
    return 'عدّات الجولة $number';
  }

  @override
  String logSetNumber(int number) {
    return 'سجّل الجولة $number';
  }

  @override
  String nextSetLabel(String name, int number) {
    return '$name · الجولة $number';
  }

  @override
  String get restOverTitle => 'خلصت الراحة';

  @override
  String get restingTitle => 'وقت الراحة';

  @override
  String get timeNextExercise => 'يلا على التمرين اللي بعده';

  @override
  String get timeNextSet => 'يلا على الجولة اللي بعدها';

  @override
  String nextColon(String what) {
    return 'اللي بعده: $what';
  }

  @override
  String logValues(String values) {
    return 'سجّل $values';
  }

  @override
  String get channelRestTimer => 'مؤقت الراحة';

  @override
  String get channelRestTimerDesc => 'ينبهك إذا خلصت الراحة بين الجولات.';

  @override
  String get channelRestCountdown => 'عدّاد الراحة';

  @override
  String get channelRestCountdownDesc =>
      'يعرض لك الراحة وهي تنقص وأنت برا التطبيق.';

  @override
  String get skipRest => 'تخطي الراحة';

  @override
  String get logSet => 'سجّل الجولة';

  @override
  String restAdd15(String value) {
    return '$value ث';
  }

  @override
  String restAdd15Notification(String value) {
    return '$value ث';
  }

  @override
  String gainReps(String value) {
    return '$value عدّة';
  }

  @override
  String get switchLanguage => 'حوّل للإنجليزي';

  @override
  String get equipmentLabel => 'الأدوات';

  @override
  String get targetMusclesLabel => 'العضلة الأساسية';

  @override
  String get secondaryMusclesLabel => 'تشتغل معها';

  @override
  String get errInvalidEmailCode =>
      'الرمز غلط أو انتهت صلاحيته. اطلب رمز جديد.';

  @override
  String get errEmailAlreadyExists => 'هذا الإيميل عليه حساب من قبل.';

  @override
  String get errEmailNotRegistered => 'ما فيه حساب بهذا الإيميل.';

  @override
  String get errTooManyEmails =>
      'طلبت رموز كثيرة لهذا الإيميل. انتظر شوي وجرّب مرة ثانية.';

  @override
  String get errEmailNotSent => 'ما قدرنا نرسل الإيميل. جرّب بعد شوي.';

  @override
  String get email => 'الإيميل';

  @override
  String get enterValidEmail => 'اكتب إيميل صحيح';

  @override
  String get emailOrUsername => 'الإيميل أو اسم المستخدم';

  @override
  String get enterEmailOrUsername => 'اكتب الإيميل أو اسم المستخدم';

  @override
  String get usernameNoAt => 'اسم المستخدم ما يكون فيه @';

  @override
  String get sendCode => 'أرسل الرمز';

  @override
  String codeSentTo(String email) {
    return 'أرسلنا رمز من 6 أرقام على $email. الرمز يشتغل لمدة 10 دقائق.';
  }

  @override
  String get checkSpam => 'ما لقيته؟ تأكد من مجلد الرسائل المزعجة (Spam).';

  @override
  String get emailCode => 'الرمز اللي وصلك';

  @override
  String get codeLength => 'الرمز 6 أرقام';

  @override
  String get resendCode => 'أرسل رمز جديد';

  @override
  String get codeResent => 'أرسلنا رمز جديد.';

  @override
  String get useAnotherEmail => 'استخدم إيميل ثاني';

  @override
  String get changeEmail => 'غيّر الإيميل';

  @override
  String get changeEmailBody =>
      'اكتب إيميلك الجديد وكلمة المرور، وبنرسل رمز على الإيميل الجديد.';

  @override
  String get newEmail => 'الإيميل الجديد';

  @override
  String get enterCodeTitle => 'اكتب الرمز';

  @override
  String get confirm => 'تأكيد';

  @override
  String get emailChanged => 'تغيّر إيميلك.';

  @override
  String get reportProblem => 'أبلغ عن مشكلة';

  @override
  String get reportIntro =>
      'وش المشكلة اللي واجهتك؟ نقرأ كل بلاغ ونرد عليك على إيميلك.';

  @override
  String get reportHint => 'اكتب وش صار، ووش كنت تسوي وقتها.';

  @override
  String get send => 'إرسال';

  @override
  String get reportSent => 'وصلنا بلاغك، شكراً لك 🙏';

  @override
  String get reportTooMany => 'أرسلت كثير في وقت قصير. جرّب بعد شوي.';

  @override
  String get suggestIdea => 'شاركنا اقتراحك';

  @override
  String get suggestIntro => 'عندك فكرة تخلّي FitPlan أحسن؟ نقرأ كل اقتراح.';

  @override
  String get suggestHint => 'اكتب فكرتك، وكيف بتفيدك.';

  @override
  String get suggestSent => 'وصلنا اقتراحك، شكراً لك 🙏';

  @override
  String get rangeAll => 'الكل';

  @override
  String get rangeWeek => 'هذا الأسبوع';

  @override
  String get rangeMonth => 'هذا الشهر';

  @override
  String get rangeYear => 'هذي السنة';

  @override
  String get noWorkoutsInRange => 'ما فيه حصص في هذي الفترة';

  @override
  String get noWorkoutsInRangeBody => 'اختر فترة أطول، أو الكل.';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get exerciseNote => 'ملاحظة التمرين';

  @override
  String get exerciseNoteBody =>
      'لك أنت، مثل رقم الكرسي اللي تضبطه. تطلع لك كل ما سويت هذا التمرين.';

  @override
  String get exerciseNoteHint => 'مثال: الكرسي على رقم 4';

  @override
  String get removeNote => 'حذف الملاحظة';
}
