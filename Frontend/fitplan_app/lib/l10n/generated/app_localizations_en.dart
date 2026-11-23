// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errUsernameAlreadyExists => 'Username is already taken.';

  @override
  String get errInvalidCredentials => 'Invalid username or password.';

  @override
  String get errInvalidRefreshToken => 'Your session has ended. Log in again.';

  @override
  String get errInvalidRecoveryCode =>
      'The username or recovery code is wrong.';

  @override
  String get errWrongPassword => 'Your password is wrong.';

  @override
  String get errUserNotFound => 'User not found.';

  @override
  String get errInvalidFile =>
      'The uploaded file is invalid. Only JPG and PNG images are allowed.';

  @override
  String get errPictureNotFound => 'There is no profile picture.';

  @override
  String get errFileTooLarge => 'The file size exceeds the 5 MB limit.';

  @override
  String get errExerciseNotFound => 'Exercise not found.';

  @override
  String get errWorkoutPlanNotFound => 'Workout plan not found.';

  @override
  String get errExerciseAlreadyExists =>
      'Exercise already exists in this workout plan.';

  @override
  String get errWorkoutPlanExerciseNotFound =>
      'Workout plan exercise not found.';

  @override
  String get errWorkoutSessionNotFound => 'Workout session not found.';

  @override
  String get errNoActiveSession => 'There is no workout session in progress.';

  @override
  String get errActiveSessionExists =>
      'You already have a workout session in progress.';

  @override
  String get errSessionNotActive =>
      'This workout session is already completed and cannot be changed.';

  @override
  String get errEmptySession =>
      'Log at least one set or cardio entry before finishing, or cancel the session.';

  @override
  String get errSessionExerciseNotFound =>
      'Exercise not found in this workout session.';

  @override
  String get errExerciseAlreadyInSession =>
      'Exercise already exists in this workout session.';

  @override
  String get errSetLimitReached =>
      'An exercise can have at most 10 sets in one session.';

  @override
  String get errSessionSetNotFound => 'Set not found.';

  @override
  String get errCardioEntryNotFound => 'Cardio entry not found.';

  @override
  String get errCardioMachineRetired =>
      'Other can\'t be chosen any more. Pick the machine, or Swimming.';

  @override
  String get errCardioDistanceTooLong =>
      'The distance can be at most 50,000 metres.';

  @override
  String get errSessionNotCompleted =>
      'This workout session is still in progress.';

  @override
  String get errNoExerciseHistory =>
      'You have not done this exercise in a finished workout yet.';

  @override
  String get errBodyWeightEntryNotFound => 'Body weight entry not found.';

  @override
  String get errTooManyRequests =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get errValidation => 'Check what you typed and try again.';

  @override
  String get errTimeout =>
      'The server took too long to answer. Try again in a moment.';

  @override
  String get errNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errServerStarting =>
      'The server is starting up. Try again in a moment.';

  @override
  String get errSomethingWrong => 'Something went wrong.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String amountKg(String amount) {
    return '$amount kg';
  }

  @override
  String volumeThousandsKg(String amount) {
    return '${amount}k kg';
  }

  @override
  String volumeThousands(String amount) {
    return '${amount}k';
  }

  @override
  String repsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
    );
    return '$_temp0';
  }

  @override
  String setWeightReps(String kg, int reps) {
    return '$kg kg × $reps';
  }

  @override
  String get durationUnderMinute => '< 1 min';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get today => 'today';

  @override
  String get yesterday => 'yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get kg => 'kg';

  @override
  String get authWrongLogin => 'Wrong username or password.';

  @override
  String get authUsernameTaken =>
      'This username is already taken. Try another one.';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get loginSubtitle =>
      'Good to see you again. Log in and pick up where you left off.';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log in';

  @override
  String get newToFitPlan => 'First time here?';

  @override
  String get createAnAccount => 'Join now';

  @override
  String get recoverySaveTitle => 'Save your recovery code';

  @override
  String get recoverySaveBody =>
      'If you forget your password, this code is the only way back into your account. Keep it somewhere safe, like a password manager. It works once, and we can\'t show it again.';

  @override
  String get recoveryCopied => 'Recovery code copied.';

  @override
  String get copyCode => 'Copy code';

  @override
  String get savedIt => 'I\'ve saved it';

  @override
  String atLeastChars(int count) {
    return 'At least $count characters';
  }

  @override
  String atMostChars(int count) {
    return 'At most $count characters';
  }

  @override
  String get registerTitle => 'Welcome to FitPlan';

  @override
  String get registerSubtitle =>
      'One quick step and you\'re in. Plan your workouts, log every set, and watch yourself get stronger.';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String passwordHint(int count) {
    return 'Use at least $count characters.';
  }

  @override
  String get createAccount => 'Let\'s go';

  @override
  String get haveAccount => 'Already one of us?';

  @override
  String get resetTitle => 'No worries, we\'ll get you back in';

  @override
  String get resetSubtitle =>
      'Enter the recovery code you saved when you joined, then pick a new password.';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get recoveryCodeLength => 'The code has 16 letters and numbers';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordLengthRange => 'Use 8 to 100 characters';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get thePasswordsDontMatch => 'The passwords don\'t match';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get rememberedIt => 'Remembered it?';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPlans => 'Plans';

  @override
  String get tabHistory => 'History';

  @override
  String get tabProgress => 'Progress';

  @override
  String decrease(String label) {
    return 'Decrease $label';
  }

  @override
  String increase(String label) {
    return 'Increase $label';
  }

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String workoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String setCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String get addToWhichPlan => 'Add to which plan?';

  @override
  String get newPlan => 'New plan';

  @override
  String get newPlanSubtitle => 'Create a plan and add it there';

  @override
  String get couldNotLoadPlans => 'Could not load your plans.';

  @override
  String get noPlansYetShort => 'You have no plans yet.';

  @override
  String get alreadyInPlan => 'Already in this plan';

  @override
  String get deletePlanTitle => 'Delete plan?';

  @override
  String deletePlanBody(String name) {
    return '\"$name\" will be deleted. Your past workouts stay in your history.';
  }

  @override
  String get keep => 'Keep';

  @override
  String get delete => 'Delete';

  @override
  String get plan => 'Plan';

  @override
  String get planOptions => 'Plan options';

  @override
  String get editName => 'Edit name';

  @override
  String get deletePlan => 'Delete plan';

  @override
  String get couldNotLoadPlan => 'Could not load this plan.';

  @override
  String get addFirstExercise => 'Add your first exercise';

  @override
  String get addFirstExerciseBody =>
      'Pick from 1,500 exercises and set your target sets and reps.';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get add => 'Add';

  @override
  String get startWorkout => 'Start workout';

  @override
  String get editPlan => 'Edit plan';

  @override
  String get name => 'Name';

  @override
  String get planNameHint => 'Push day';

  @override
  String get planNameRequired => 'Give your plan a name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get planDescriptionHint => 'Chest, shoulders and triceps';

  @override
  String get createPlan => 'Create plan';

  @override
  String get save => 'Save';

  @override
  String get plansTitle => 'Plans';

  @override
  String get browseExercises => 'Browse exercises';

  @override
  String get plansSubtitle => 'Your routines. Start one and log as you go.';

  @override
  String get noPlansYet => 'No plans yet';

  @override
  String get noPlansYetBody =>
      'Make a plan like \"Push day\" and add the exercises you do.';

  @override
  String get createAPlan => 'Create a plan';

  @override
  String get quickWorkoutNoPlan => 'Quick workout, no plan';

  @override
  String get noExercisesYet => 'No exercises yet';

  @override
  String startPlan(String name) {
    return 'Start $name';
  }

  @override
  String get targetSubtitle => 'Your target for each workout';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get restBetweenSets => 'Rest between sets';

  @override
  String get addToPlan => 'Add to plan';

  @override
  String get removeFromPlan => 'Remove from plan';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greeting(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get readyToTrain => 'Ready to train?';

  @override
  String get profile => 'Profile';

  @override
  String get openProfile => 'Open profile';

  @override
  String get inProgress => 'IN PROGRESS';

  @override
  String setsLoggedSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets logged so far',
      one: '1 set logged so far',
    );
    return '$_temp0';
  }

  @override
  String get resumeWorkout => 'Resume workout';

  @override
  String get upNext => 'UP NEXT';

  @override
  String get chooseAnotherPlan => 'Choose another plan';

  @override
  String get getStarted => 'GET STARTED';

  @override
  String get makeFirstPlan => 'Make your first plan';

  @override
  String get makeFirstPlanBody =>
      'Pick your exercises once, then start it with one tap every time you train.';

  @override
  String get goToPlans => 'Go to plans';

  @override
  String get quickWorkout => 'Quick workout';

  @override
  String get thisWeek => 'This week';

  @override
  String weekGoalMet(int count) {
    return '$count workouts · goal met';
  }

  @override
  String weekOfGoal(int count, int goal) {
    return '$count of $goal workouts';
  }

  @override
  String get noWorkoutsYet => 'No workouts yet';

  @override
  String trainedDaysSemantics(int days) {
    return 'Trained on $days of 7 days this week';
  }

  @override
  String get lastSession => 'Last session';

  @override
  String get bodyChest => 'Chest';

  @override
  String get bodyBack => 'Back';

  @override
  String get bodyShoulders => 'Shoulders';

  @override
  String get bodyUpperArms => 'Upper arms';

  @override
  String get bodyLowerArms => 'Lower arms';

  @override
  String get bodyUpperLegs => 'Upper legs';

  @override
  String get bodyLowerLegs => 'Lower legs';

  @override
  String get bodyWaist => 'Waist';

  @override
  String get bodyNeck => 'Neck';

  @override
  String get bodyCardio => 'Cardio';

  @override
  String get howToDoIt => 'How to do it';

  @override
  String get couldNotLoadInstructions => 'Could not load the instructions.';

  @override
  String get noInstructions => 'No instructions for this exercise yet.';

  @override
  String get addToAPlan => 'Add to a plan';

  @override
  String addedTo(String name) {
    return 'Added to $name';
  }

  @override
  String get open => 'Open';

  @override
  String get exercises => 'Exercises';

  @override
  String get searchExercises => 'Search exercises';

  @override
  String get clear => 'Clear';

  @override
  String get all => 'All';

  @override
  String get couldNotLoadExercises => 'Could not load exercises.';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get noExercisesFoundBody => 'Try another word or body part.';

  @override
  String get loadMore => 'Load more';

  @override
  String addExerciseToPlanTooltip(String name) {
    return 'Add $name to a plan';
  }

  @override
  String addExerciseTooltip(String name) {
    return 'Add $name';
  }

  @override
  String bodyPartAdded(String part) {
    return '$part · added';
  }

  @override
  String howToDo(String name) {
    return 'How to do $name';
  }

  @override
  String get alreadyAdded => 'Already added';

  @override
  String get showHowToDoIt => 'Show how to do it';

  @override
  String get demoNotAvailableFull =>
      'Demo not available. Follow the steps below.';

  @override
  String get demoNotAvailable => 'Demo not available';

  @override
  String get followStepsBelow => 'Follow the steps below.';

  @override
  String get couldNotLoadHistory => 'Could not load your history.';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'Every workout you finished.';

  @override
  String get noHistoryBody =>
      'Finish your first workout and it will show up here.';

  @override
  String get time => 'Time';

  @override
  String get volume => 'Volume';

  @override
  String get kcal => 'kcal';

  @override
  String get cardio => 'Cardio';

  @override
  String get deleteWorkoutTitle => 'Delete workout?';

  @override
  String deleteWorkoutBody(String name) {
    return '\"$name\" and all its sets will be deleted. This cannot be undone.';
  }

  @override
  String get workout => 'Workout';

  @override
  String get workoutOptions => 'Workout options';

  @override
  String get deleteWorkout => 'Delete workout';

  @override
  String get couldNotLoadWorkout => 'Could not load this workout.';

  @override
  String topSet(String kg) {
    return 'Top set $kg kg';
  }

  @override
  String get bodyweight => 'Bodyweight';

  @override
  String kcalAmount(int amount) {
    return '≈ $amount kcal';
  }

  @override
  String get couldNotLoadProfile => 'Could not load your profile.';

  @override
  String get logOut => 'Log out';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get viewProfilePhoto => 'View profile photo';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get addPhoto => 'Add photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get close => 'Close';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get cancel => 'Cancel';

  @override
  String get newRecoveryCodeTitle => 'New recovery code';

  @override
  String get newRecoveryCodeBody =>
      'Your old code will stop working. Enter your password to continue.';

  @override
  String get createCode => 'Create code';

  @override
  String get recoveryHasCode =>
      'You can reset a forgotten password with your recovery code. Lost it? Create a new one.';

  @override
  String get recoveryNoCode =>
      'You don\'t have a recovery code yet. Without one, a forgotten password means a lost account.';

  @override
  String get createNewCode => 'Create a new code';

  @override
  String get createRecoveryCode => 'Create a recovery code';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This deletes your plans, workouts, weights and photo for good. It can\'t be undone. Enter your password to confirm.';

  @override
  String get accountDeleted => 'Your account was deleted.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get bodyWeight => 'Body weight';

  @override
  String get addWeightHint =>
      'Add your weight so we can estimate the calories you burn.';

  @override
  String get update => 'Update';

  @override
  String get enterNumber => 'Enter a number, e.g. 78.5';

  @override
  String weightRange(int min, int max) {
    return 'Between $min and $max kg';
  }

  @override
  String get todaysWeight => 'Today\'s weight';

  @override
  String get weightTrendNote =>
      'We keep every entry, so you can follow the trend.';

  @override
  String get weight => 'Weight';

  @override
  String get bioSaved => 'Bio saved';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Your goals, your favorite lift, anything…';

  @override
  String get saveBio => 'Save bio';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Auto';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get tonnes => 't';

  @override
  String get msPiano => 'a grand piano';

  @override
  String get msPianoPlural => 'grand pianos';

  @override
  String get msCar => 'a small car';

  @override
  String get msCarPlural => 'small cars';

  @override
  String get msElephant => 'an elephant';

  @override
  String get msElephantPlural => 'elephants';

  @override
  String get msBus => 'a city bus';

  @override
  String get msBusPlural => 'city buses';

  @override
  String get msTruck => 'a loaded truck';

  @override
  String get msTruckPlural => 'loaded trucks';

  @override
  String get msWhale => 'a blue whale';

  @override
  String get msWhalePlural => 'blue whales';

  @override
  String get msJet => 'a jumbo jet at takeoff';

  @override
  String get msJetPlural => 'jumbo jets';

  @override
  String get msLondonEye => 'the London Eye';

  @override
  String get msLondonEyePlural => 'London Eyes';

  @override
  String get msEiffel => 'the Eiffel Tower';

  @override
  String get msEiffelPlural => 'Eiffel Towers';

  @override
  String aboutOne(String name) {
    return 'About $name';
  }

  @override
  String aboutMany(String count, String name) {
    return 'About $count $name';
  }

  @override
  String get couldNotLoadProgress => 'Could not load your progress.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'What your training adds up to.';

  @override
  String get streakNoGoal =>
      'A week counts when you train at least once. Set a goal to aim higher.';

  @override
  String streakGoalReached(int done, int goal) {
    return '$done workouts this week, goal of $goal reached. Nice.';
  }

  @override
  String streakToGo(int done, int goal, int left) {
    return '$done of $goal this week, $left to go.';
  }

  @override
  String get noStreakYet => 'No streak yet';

  @override
  String weekStreak(int count) {
    return '$count-week streak';
  }

  @override
  String get setGoal => 'Set goal';

  @override
  String get aWeek => 'a week';

  @override
  String get vsLastWeek => '▲ vs last week';

  @override
  String get workouts => 'Workouts';

  @override
  String get kgLifted => 'Kg lifted';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get same => 'same';

  @override
  String get strength => 'Strength';

  @override
  String get body => 'Body';

  @override
  String get chooseExercise => 'Choose an exercise';

  @override
  String get strengthEmpty =>
      'Finish a workout and your strength trend shows up here.';

  @override
  String fromLastWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'From your last $count workouts',
      one: 'From your last workout',
    );
    return '$_temp0';
  }

  @override
  String latestBest(String kg, String set) {
    return 'Latest workout · best $kg kg from $set';
  }

  @override
  String get estimated1rm => 'estimated 1RM';

  @override
  String get topSetLabel => 'top set';

  @override
  String get bestReps => 'best reps';

  @override
  String get repsUnit => 'reps';

  @override
  String get logWeightTrend => 'Log your weight to see its trend.';

  @override
  String get logWeight => 'Log weight';

  @override
  String latestWeighIn(String when) {
    return 'Latest weigh-in, $when';
  }

  @override
  String get recentRecords => 'Recent records';

  @override
  String get weeklyVolume => 'Weekly volume';

  @override
  String get kgLiftedLower => 'kg lifted';

  @override
  String get weighIns => 'Weigh-ins';

  @override
  String get logTodaysWeight => 'Log today\'s weight';

  @override
  String recordsMeta(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0 · last $when';
  }

  @override
  String get recordHeaviest => 'Heaviest weight';

  @override
  String get recordEstimated1rm => 'Estimated 1RM';

  @override
  String get recordMostReps => 'Most reps';

  @override
  String get recordBestSetVolume => 'Best set volume';

  @override
  String get finishWithWeights => 'Finish a workout with weights to start';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get lifetimeVolume => 'LIFETIME VOLUME';

  @override
  String nextMilestone(String name) {
    return 'Next: $name';
  }

  @override
  String toGo(String amount) {
    return '$amount to go';
  }

  @override
  String get allMilestones => 'Every milestone reached. Legendary.';

  @override
  String get milestones => 'Milestones';

  @override
  String liftedSoFar(String amount) {
    return '$amount lifted so far';
  }

  @override
  String get milestonesNote =>
      'Weights are approximate. Volume is reps × weight from finished workouts. Bodyweight sets and cardio aren\'t counted.';

  @override
  String reachedOn(String date) {
    return 'Reached $date';
  }

  @override
  String get weeklyGoal => 'Weekly goal';

  @override
  String get weeklyGoalBody =>
      'Workouts per week. Hit it and your streak grows.';

  @override
  String get noGoal => 'No goal';

  @override
  String goalPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts a week',
      one: '1 workout a week',
    );
    return '$_temp0';
  }

  @override
  String firstTimeWith(String name) {
    return 'First time with \"$name\". Next time you will see how you compare.';
  }

  @override
  String personalRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personal records',
      one: '1 personal record',
    );
    return '$_temp0';
  }

  @override
  String volumeVsLast(String name) {
    return 'Volume vs last $name';
  }

  @override
  String lastTimeWas(String when) {
    return 'Last time was $when';
  }

  @override
  String get todayLabel => 'Today';

  @override
  String get lastLabel => 'Last';

  @override
  String setWeightRepsShort(String kg, int reps) {
    return '$kg × $reps';
  }

  @override
  String get nothingLoggedYet => 'Nothing logged yet';

  @override
  String get oneMoreEntry => 'One more entry and the trend starts here';

  @override
  String trendSemantics(String from, String to, String unit) {
    return 'Trend from $from to $to $unit';
  }

  @override
  String weekBarsSemantics(String now, String last) {
    return 'This week $now, last week $last';
  }

  @override
  String weekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get thisWeekLabel => 'This week';

  @override
  String get cfSpeed => 'Speed';

  @override
  String get cfIncline => 'Incline';

  @override
  String get cfDistance => 'Distance';

  @override
  String get cfLevel => 'Level';

  @override
  String get cfDamper => 'Damper';

  @override
  String get cfFloors => 'Floors';

  @override
  String get cfCadence => 'Cadence';

  @override
  String get cfStrokeRate => 'Stroke rate';

  @override
  String get cfPoolLength => 'Pool length';

  @override
  String get cfLaps => 'Laps';

  @override
  String get unitKmh => 'km/h';

  @override
  String get unitKm => 'km';

  @override
  String get unitM => 'm';

  @override
  String cardioRange(String label, String min, String max, String unit) {
    return '$label: $min to $max$unit';
  }

  @override
  String get cmTreadmill => 'Treadmill';

  @override
  String get cmStairs => 'Stairs';

  @override
  String get cmBike => 'Bike';

  @override
  String get cmElliptical => 'Elliptical';

  @override
  String get cmRower => 'Rower';

  @override
  String get cmSwimming => 'Swimming';

  @override
  String get cmOther => 'Other';

  @override
  String get whyIncrease => 'you hit every rep last time';

  @override
  String get whyRepeat => 'same weight, beat the reps';

  @override
  String get whyDeload => 'lighter to recover after two tough workouts';

  @override
  String get whyMoreReps => 'one more rep than your best';

  @override
  String cdSpeed(String value) {
    return '$value km/h';
  }

  @override
  String cdIncline(String value) {
    return '$value% incline';
  }

  @override
  String cdKm(String value) {
    return '$value km';
  }

  @override
  String cdMeters(int value) {
    return '$value m';
  }

  @override
  String cdDamper(int value) {
    return 'Damper $value';
  }

  @override
  String cdLevel(int value) {
    return 'Level $value';
  }

  @override
  String cdFloors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count floors',
      one: '1 floor',
    );
    return '$_temp0';
  }

  @override
  String cdLapsOf(int count, int pool) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count laps of $pool m',
      one: '1 lap of $pool m',
    );
    return '$_temp0';
  }

  @override
  String cdLaps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count laps',
      one: '1 lap',
    );
    return '$_temp0';
  }

  @override
  String cdPool(int value) {
    return '$value m pool';
  }

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get durationRange => 'Duration: 1 to 300 minutes';

  @override
  String get addCardio => 'Add cardio';

  @override
  String get howLong => 'How long?';

  @override
  String get minUnit => 'min';

  @override
  String get moreDetails => 'More details (optional)';

  @override
  String get swimDistanceNote =>
      'Laps and pool length are enough: the distance is worked out for you.';

  @override
  String get caloriesRough => 'Calories are a rough estimate.';

  @override
  String get caloriesRoughMachine =>
      'Calories are a rough estimate, since machines measure effort differently.';

  @override
  String get addWeightForCalories =>
      'Add your weight in Profile to see the calories you burn.';

  @override
  String get finishWorkoutTitle => 'Finish workout?';

  @override
  String get finishAllDone => 'Nice, you did everything you planned.';

  @override
  String finishUnfinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count exercises are not complete. You can still finish, what you logged is saved.',
      one: '1 exercise is not complete. You can still finish, what you logged is saved.',
    );
    return '$_temp0';
  }

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get howDidItFeel => 'How did it feel?';

  @override
  String get finishWorkout => 'Finish workout';

  @override
  String get keepTraining => 'Keep training';

  @override
  String addedToPlan(String what, String name) {
    return 'Added $what to $name';
  }

  @override
  String addToPlanQuestion(String name) {
    return 'Add to $name?';
  }

  @override
  String get planAdditionsBody =>
      'You added these during this workout. Choose which to keep in your plan.';

  @override
  String addCountToPlan(int count) {
    return 'Add $count to plan';
  }

  @override
  String get notNow => 'Not now';

  @override
  String addName(String name) {
    return 'Add $name';
  }

  @override
  String targetForSemantics(String name, String target) {
    return 'Target for $name: $target. Tap to change.';
  }

  @override
  String get discardWorkoutTitle => 'Discard workout?';

  @override
  String get discardWorkoutBody =>
      'Everything you logged in this workout will be deleted.';

  @override
  String get keepGoingButton => 'Keep going';

  @override
  String get discard => 'Discard';

  @override
  String get noCardioToday => 'No cardio today?';

  @override
  String get cardioReminderBody =>
      'A few minutes of cardio is a good way to finish. It is up to you.';

  @override
  String get finishWithoutCardio => 'Finish without cardio';

  @override
  String get logSomethingFirst =>
      'Log at least one set or some cardio first, or discard the workout.';

  @override
  String get couldNotLoadSession => 'Could not load your workout.';

  @override
  String get noWorkoutInProgress => 'No workout in progress';

  @override
  String get noWorkoutInProgressBody =>
      'Start one from a plan, or a quick workout.';

  @override
  String get back => 'Back';

  @override
  String get minimise => 'Minimise';

  @override
  String get discardWorkout => 'Discard workout';

  @override
  String get finish => 'Finish';

  @override
  String doneOfTotal(int done, int total) {
    return '$done OF $total DONE';
  }

  @override
  String get quickWorkoutOverline => 'QUICK WORKOUT';

  @override
  String get whatTraining => 'What are you training?';

  @override
  String get quickWorkoutBody =>
      'Add exercises as you go, or just log some cardio.';

  @override
  String setsLoggedOfTarget(int logged, int target) {
    return '$logged / $target sets';
  }

  @override
  String exerciseRowSemantics(
    int number,
    String name,
    String progress,
    String done,
    String active,
  ) {
    return '$number. $name, $progress$done$active. Tap to open.';
  }

  @override
  String get semDone => ', done';

  @override
  String get semDoThisNow => ', do this now';

  @override
  String progressWithTarget(String progress, int sets, int reps) {
    return '$progress · target $sets × $reps';
  }

  @override
  String get cardioFinishPrompt =>
      'Finish with some cardio? Pick the machine and how long.';

  @override
  String get noKcal => '— kcal';

  @override
  String get deleteCardio => 'Delete cardio';

  @override
  String get workoutInProgressTitle => 'Workout in progress';

  @override
  String workoutInProgressBody(String name) {
    return 'You have \"$name\" running. Finish or cancel it before starting a new one.';
  }

  @override
  String get resume => 'Resume';

  @override
  String get duration => 'Duration';

  @override
  String get caloriesEstimated => 'Calories (estimated)';

  @override
  String get calories => 'Calories';

  @override
  String get addWeightInProfile => 'Add weight in Profile';

  @override
  String get workoutComplete => 'Workout complete';

  @override
  String thisWorkoutCompare(String comparison) {
    return 'This workout: $comparison';
  }

  @override
  String get done => 'Done';

  @override
  String get newMilestone => 'NEW MILESTONE';

  @override
  String youLifted(String name) {
    return 'You\'ve lifted $name';
  }

  @override
  String totalPassed(String amount, String name) {
    return 'Your total passed $amount, about the weight of $name';
  }

  @override
  String passedOnTheWay(String names) {
    return 'And passed $names on the way';
  }

  @override
  String get and => ' and ';

  @override
  String get removeExerciseTitle => 'Remove exercise?';

  @override
  String removeExerciseBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count logged sets of this exercise will be deleted.',
      one: 'The 1 logged set of this exercise will be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get remove => 'Remove';

  @override
  String targetSetsReps(int sets, int reps) {
    return 'Target $sets × $reps';
  }

  @override
  String closeName(String name) {
    return 'Close $name';
  }

  @override
  String get exerciseOptions => 'Exercise options';

  @override
  String get removeFromWorkout => 'Remove from workout';

  @override
  String get addSet => 'Add set';

  @override
  String get nextExercise => 'Next exercise';

  @override
  String get now => 'NOW';

  @override
  String restChipSemantics(String time) {
    return 'Rest $time between sets. Tap to change.';
  }

  @override
  String restChip(String time) {
    return 'Rest $time';
  }

  @override
  String suggestedToday(String target, String why) {
    return 'Suggested today: $target, $why';
  }

  @override
  String get todayPrefix => 'Today  ';

  @override
  String get firstTimeExercise =>
      'First time doing this one. Today sets your baseline.';

  @override
  String lastTimeWhen(String when) {
    return 'Last time · $when';
  }

  @override
  String get bodyweightShort => 'BW';

  @override
  String get restSheetBody =>
      'Rest after each set, for this workout. Your plan stays as it is.';

  @override
  String get restDone => 'REST DONE';

  @override
  String get rest => 'REST';

  @override
  String get go => 'Go!';

  @override
  String get skip => 'Skip';

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get emptyIsBodyweight => 'Empty = bodyweight';

  @override
  String get deleteSet => 'Delete set';

  @override
  String repsRange(int max) {
    return 'Reps: 1 to $max';
  }

  @override
  String weightRangeSet(String max) {
    return 'Weight: 0 to $max kg';
  }

  @override
  String get colSet => 'SET';

  @override
  String get colKg => 'KG';

  @override
  String get colReps => 'REPS';

  @override
  String setDoneSemantics(int number, String weight, int reps) {
    return 'Set $number: $weight, $reps reps, done. Tap to edit.';
  }

  @override
  String get semBodyweight => 'bodyweight';

  @override
  String semKilograms(String kg) {
    return '$kg kilograms';
  }

  @override
  String setWeightSemantics(int number) {
    return 'Set $number weight in kilograms';
  }

  @override
  String setRepsSemantics(int number) {
    return 'Set $number reps';
  }

  @override
  String logSetNumber(int number) {
    return 'Log set $number';
  }

  @override
  String nextSetLabel(String name, int number) {
    return '$name · set $number';
  }

  @override
  String get restOverTitle => 'Rest is over';

  @override
  String get restingTitle => 'Resting';

  @override
  String get timeNextExercise => 'Time for your next exercise';

  @override
  String get timeNextSet => 'Time for your next set';

  @override
  String nextColon(String what) {
    return 'Next: $what';
  }

  @override
  String logValues(String values) {
    return 'Log $values';
  }

  @override
  String get channelRestTimer => 'Rest timer';

  @override
  String get channelRestTimerDesc =>
      'Tells you when your rest between sets is over.';

  @override
  String get channelRestCountdown => 'Rest countdown';

  @override
  String get channelRestCountdownDesc =>
      'Shows the rest counting down while you are outside the app.';

  @override
  String get skipRest => 'Skip rest';

  @override
  String get logSet => 'Log set';

  @override
  String restAdd15(String value) {
    return '${value}s';
  }

  @override
  String restAdd15Notification(String value) {
    return '$value s';
  }

  @override
  String gainReps(String value) {
    return '$value reps';
  }

  @override
  String get switchLanguage => 'Switch to Arabic';

  @override
  String get equipmentLabel => 'Equipment';

  @override
  String get targetMusclesLabel => 'Main muscle';

  @override
  String get secondaryMusclesLabel => 'Also works';
}
