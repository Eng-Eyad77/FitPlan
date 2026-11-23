import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// No description provided for @errUsernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken.'**
  String get errUsernameAlreadyExists;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get errInvalidCredentials;

  /// No description provided for @errInvalidRefreshToken.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Log in again.'**
  String get errInvalidRefreshToken;

  /// No description provided for @errInvalidRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'The username or recovery code is wrong.'**
  String get errInvalidRecoveryCode;

  /// No description provided for @errWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password is wrong.'**
  String get errWrongPassword;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errUserNotFound;

  /// No description provided for @errInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'The uploaded file is invalid. Only JPG and PNG images are allowed.'**
  String get errInvalidFile;

  /// No description provided for @errPictureNotFound.
  ///
  /// In en, this message translates to:
  /// **'There is no profile picture.'**
  String get errPictureNotFound;

  /// No description provided for @errFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file size exceeds the 5 MB limit.'**
  String get errFileTooLarge;

  /// No description provided for @errExerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found.'**
  String get errExerciseNotFound;

  /// No description provided for @errWorkoutPlanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout plan not found.'**
  String get errWorkoutPlanNotFound;

  /// No description provided for @errExerciseAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Exercise already exists in this workout plan.'**
  String get errExerciseAlreadyExists;

  /// No description provided for @errWorkoutPlanExerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout plan exercise not found.'**
  String get errWorkoutPlanExerciseNotFound;

  /// No description provided for @errWorkoutSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout session not found.'**
  String get errWorkoutSessionNotFound;

  /// No description provided for @errNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'There is no workout session in progress.'**
  String get errNoActiveSession;

  /// No description provided for @errActiveSessionExists.
  ///
  /// In en, this message translates to:
  /// **'You already have a workout session in progress.'**
  String get errActiveSessionExists;

  /// No description provided for @errSessionNotActive.
  ///
  /// In en, this message translates to:
  /// **'This workout session is already completed and cannot be changed.'**
  String get errSessionNotActive;

  /// No description provided for @errEmptySession.
  ///
  /// In en, this message translates to:
  /// **'Log at least one set or cardio entry before finishing, or cancel the session.'**
  String get errEmptySession;

  /// No description provided for @errSessionExerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found in this workout session.'**
  String get errSessionExerciseNotFound;

  /// No description provided for @errExerciseAlreadyInSession.
  ///
  /// In en, this message translates to:
  /// **'Exercise already exists in this workout session.'**
  String get errExerciseAlreadyInSession;

  /// No description provided for @errSetLimitReached.
  ///
  /// In en, this message translates to:
  /// **'An exercise can have at most 10 sets in one session.'**
  String get errSetLimitReached;

  /// No description provided for @errSessionSetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Set not found.'**
  String get errSessionSetNotFound;

  /// No description provided for @errCardioEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cardio entry not found.'**
  String get errCardioEntryNotFound;

  /// No description provided for @errCardioMachineRetired.
  ///
  /// In en, this message translates to:
  /// **'Other can\'t be chosen any more. Pick the machine, or Swimming.'**
  String get errCardioMachineRetired;

  /// No description provided for @errCardioDistanceTooLong.
  ///
  /// In en, this message translates to:
  /// **'The distance can be at most 50,000 metres.'**
  String get errCardioDistanceTooLong;

  /// No description provided for @errSessionNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'This workout session is still in progress.'**
  String get errSessionNotCompleted;

  /// No description provided for @errNoExerciseHistory.
  ///
  /// In en, this message translates to:
  /// **'You have not done this exercise in a finished workout yet.'**
  String get errNoExerciseHistory;

  /// No description provided for @errBodyWeightEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Body weight entry not found.'**
  String get errBodyWeightEntryNotFound;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get errTooManyRequests;

  /// No description provided for @errValidation.
  ///
  /// In en, this message translates to:
  /// **'Check what you typed and try again.'**
  String get errValidation;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer. Try again in a moment.'**
  String get errTimeout;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errNetwork;

  /// No description provided for @errServerStarting.
  ///
  /// In en, this message translates to:
  /// **'The server is starting up. Try again in a moment.'**
  String get errServerStarting;

  /// No description provided for @errSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errSomethingWrong;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @amountKg.
  ///
  /// In en, this message translates to:
  /// **'{amount} kg'**
  String amountKg(String amount);

  /// No description provided for @volumeThousandsKg.
  ///
  /// In en, this message translates to:
  /// **'{amount}k kg'**
  String volumeThousandsKg(String amount);

  /// No description provided for @volumeThousands.
  ///
  /// In en, this message translates to:
  /// **'{amount}k'**
  String volumeThousands(String amount);

  /// No description provided for @repsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} reps}}'**
  String repsCount(int count);

  /// No description provided for @setWeightReps.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg × {reps}'**
  String setWeightReps(String kg, int reps);

  /// No description provided for @durationUnderMinute.
  ///
  /// In en, this message translates to:
  /// **'< 1 min'**
  String get durationUnderMinute;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @authWrongLogin.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get authWrongLogin;

  /// No description provided for @authUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Try another one.'**
  String get authUsernameTaken;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Good to see you again. Log in and pick up where you left off.'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @newToFitPlan.
  ///
  /// In en, this message translates to:
  /// **'First time here?'**
  String get newToFitPlan;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Join now'**
  String get createAnAccount;

  /// No description provided for @recoverySaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your recovery code'**
  String get recoverySaveTitle;

  /// No description provided for @recoverySaveBody.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password, this code is the only way back into your account. Keep it somewhere safe, like a password manager. It works once, and we can\'t show it again.'**
  String get recoverySaveBody;

  /// No description provided for @recoveryCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied.'**
  String get recoveryCopied;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @savedIt.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved it'**
  String get savedIt;

  /// No description provided for @atLeastChars.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String atLeastChars(int count);

  /// No description provided for @atMostChars.
  ///
  /// In en, this message translates to:
  /// **'At most {count} characters'**
  String atMostChars(int count);

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FitPlan'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One quick step and you\'re in. Plan your workouts, log every set, and watch yourself get stronger.'**
  String get registerSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String passwordHint(int count);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already one of us?'**
  String get haveAccount;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'No worries, we\'ll get you back in'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery code you saved when you joined, then pick a new password.'**
  String get resetSubtitle;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @recoveryCodeLength.
  ///
  /// In en, this message translates to:
  /// **'The code has 16 letters and numbers'**
  String get recoveryCodeLength;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordLengthRange.
  ///
  /// In en, this message translates to:
  /// **'Use 8 to 100 characters'**
  String get passwordLengthRange;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @thePasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match'**
  String get thePasswordsDontMatch;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @rememberedIt.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get rememberedIt;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get tabPlans;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease {label}'**
  String decrease(String label);

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase {label}'**
  String increase(String label);

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(int count);

  /// No description provided for @workoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}}'**
  String workoutCount(int count);

  /// No description provided for @setCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String setCount(int count);

  /// No description provided for @addToWhichPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to which plan?'**
  String get addToWhichPlan;

  /// No description provided for @newPlan.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get newPlan;

  /// No description provided for @newPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a plan and add it there'**
  String get newPlanSubtitle;

  /// No description provided for @couldNotLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Could not load your plans.'**
  String get couldNotLoadPlans;

  /// No description provided for @noPlansYetShort.
  ///
  /// In en, this message translates to:
  /// **'You have no plans yet.'**
  String get noPlansYetShort;

  /// No description provided for @alreadyInPlan.
  ///
  /// In en, this message translates to:
  /// **'Already in this plan'**
  String get alreadyInPlan;

  /// No description provided for @deletePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plan?'**
  String get deletePlanTitle;

  /// No description provided for @deletePlanBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted. Your past workouts stay in your history.'**
  String deletePlanBody(String name);

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @planOptions.
  ///
  /// In en, this message translates to:
  /// **'Plan options'**
  String get planOptions;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get deletePlan;

  /// No description provided for @couldNotLoadPlan.
  ///
  /// In en, this message translates to:
  /// **'Could not load this plan.'**
  String get couldNotLoadPlan;

  /// No description provided for @addFirstExercise.
  ///
  /// In en, this message translates to:
  /// **'Add your first exercise'**
  String get addFirstExercise;

  /// No description provided for @addFirstExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'Pick from 1,500 exercises and set your target sets and reps.'**
  String get addFirstExerciseBody;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get editPlan;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @planNameHint.
  ///
  /// In en, this message translates to:
  /// **'Push day'**
  String get planNameHint;

  /// No description provided for @planNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your plan a name'**
  String get planNameRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @planDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Chest, shoulders and triceps'**
  String get planDescriptionHint;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get createPlan;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @browseExercises.
  ///
  /// In en, this message translates to:
  /// **'Browse exercises'**
  String get browseExercises;

  /// No description provided for @plansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your routines. Start one and log as you go.'**
  String get plansSubtitle;

  /// No description provided for @noPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No plans yet'**
  String get noPlansYet;

  /// No description provided for @noPlansYetBody.
  ///
  /// In en, this message translates to:
  /// **'Make a plan like \"Push day\" and add the exercises you do.'**
  String get noPlansYetBody;

  /// No description provided for @createAPlan.
  ///
  /// In en, this message translates to:
  /// **'Create a plan'**
  String get createAPlan;

  /// No description provided for @quickWorkoutNoPlan.
  ///
  /// In en, this message translates to:
  /// **'Quick workout, no plan'**
  String get quickWorkoutNoPlan;

  /// No description provided for @noExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get noExercisesYet;

  /// No description provided for @startPlan.
  ///
  /// In en, this message translates to:
  /// **'Start {name}'**
  String startPlan(String name);

  /// No description provided for @targetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your target for each workout'**
  String get targetSubtitle;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @restBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get restBetweenSets;

  /// No description provided for @addToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get addToPlan;

  /// No description provided for @removeFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Remove from plan'**
  String get removeFromPlan;

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

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greeting(String greeting, String name);

  /// No description provided for @readyToTrain.
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get readyToTrain;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgress;

  /// No description provided for @setsLoggedSoFar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set logged so far} other{{count} sets logged so far}}'**
  String setsLoggedSoFar(int count);

  /// No description provided for @resumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume workout'**
  String get resumeWorkout;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get upNext;

  /// No description provided for @chooseAnotherPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose another plan'**
  String get chooseAnotherPlan;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @makeFirstPlan.
  ///
  /// In en, this message translates to:
  /// **'Make your first plan'**
  String get makeFirstPlan;

  /// No description provided for @makeFirstPlanBody.
  ///
  /// In en, this message translates to:
  /// **'Pick your exercises once, then start it with one tap every time you train.'**
  String get makeFirstPlanBody;

  /// No description provided for @goToPlans.
  ///
  /// In en, this message translates to:
  /// **'Go to plans'**
  String get goToPlans;

  /// No description provided for @quickWorkout.
  ///
  /// In en, this message translates to:
  /// **'Quick workout'**
  String get quickWorkout;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @weekGoalMet.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts · goal met'**
  String weekGoalMet(int count);

  /// No description provided for @weekOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{count} of {goal} workouts'**
  String weekOfGoal(int count, int goal);

  /// No description provided for @noWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// No description provided for @trainedDaysSemantics.
  ///
  /// In en, this message translates to:
  /// **'Trained on {days} of 7 days this week'**
  String trainedDaysSemantics(int days);

  /// No description provided for @lastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get lastSession;

  /// No description provided for @bodyChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get bodyChest;

  /// No description provided for @bodyBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get bodyBack;

  /// No description provided for @bodyShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get bodyShoulders;

  /// No description provided for @bodyUpperArms.
  ///
  /// In en, this message translates to:
  /// **'Upper arms'**
  String get bodyUpperArms;

  /// No description provided for @bodyLowerArms.
  ///
  /// In en, this message translates to:
  /// **'Lower arms'**
  String get bodyLowerArms;

  /// No description provided for @bodyUpperLegs.
  ///
  /// In en, this message translates to:
  /// **'Upper legs'**
  String get bodyUpperLegs;

  /// No description provided for @bodyLowerLegs.
  ///
  /// In en, this message translates to:
  /// **'Lower legs'**
  String get bodyLowerLegs;

  /// No description provided for @bodyWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get bodyWaist;

  /// No description provided for @bodyNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get bodyNeck;

  /// No description provided for @bodyCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get bodyCardio;

  /// No description provided for @howToDoIt.
  ///
  /// In en, this message translates to:
  /// **'How to do it'**
  String get howToDoIt;

  /// No description provided for @couldNotLoadInstructions.
  ///
  /// In en, this message translates to:
  /// **'Could not load the instructions.'**
  String get couldNotLoadInstructions;

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions for this exercise yet.'**
  String get noInstructions;

  /// No description provided for @addToAPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to a plan'**
  String get addToAPlan;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedTo(String name);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get searchExercises;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @couldNotLoadExercises.
  ///
  /// In en, this message translates to:
  /// **'Could not load exercises.'**
  String get couldNotLoadExercises;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @noExercisesFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word or body part.'**
  String get noExercisesFoundBody;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @addExerciseToPlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add {name} to a plan'**
  String addExerciseToPlanTooltip(String name);

  /// No description provided for @addExerciseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addExerciseTooltip(String name);

  /// No description provided for @bodyPartAdded.
  ///
  /// In en, this message translates to:
  /// **'{part} · added'**
  String bodyPartAdded(String part);

  /// No description provided for @howToDo.
  ///
  /// In en, this message translates to:
  /// **'How to do {name}'**
  String howToDo(String name);

  /// No description provided for @alreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get alreadyAdded;

  /// No description provided for @showHowToDoIt.
  ///
  /// In en, this message translates to:
  /// **'Show how to do it'**
  String get showHowToDoIt;

  /// No description provided for @demoNotAvailableFull.
  ///
  /// In en, this message translates to:
  /// **'Demo not available. Follow the steps below.'**
  String get demoNotAvailableFull;

  /// No description provided for @demoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Demo not available'**
  String get demoNotAvailable;

  /// No description provided for @followStepsBelow.
  ///
  /// In en, this message translates to:
  /// **'Follow the steps below.'**
  String get followStepsBelow;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load your history.'**
  String get couldNotLoadHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every workout you finished.'**
  String get historySubtitle;

  /// No description provided for @noHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Finish your first workout and it will show up here.'**
  String get noHistoryBody;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout?'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and all its sets will be deleted. This cannot be undone.'**
  String deleteWorkoutBody(String name);

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @workoutOptions.
  ///
  /// In en, this message translates to:
  /// **'Workout options'**
  String get workoutOptions;

  /// No description provided for @deleteWorkout.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get deleteWorkout;

  /// No description provided for @couldNotLoadWorkout.
  ///
  /// In en, this message translates to:
  /// **'Could not load this workout.'**
  String get couldNotLoadWorkout;

  /// No description provided for @topSet.
  ///
  /// In en, this message translates to:
  /// **'Top set {kg} kg'**
  String topSet(String kg);

  /// No description provided for @bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get bodyweight;

  /// No description provided for @kcalAmount.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} kcal'**
  String kcalAmount(int amount);

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get couldNotLoadProfile;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @viewProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'View profile photo'**
  String get viewProfilePhoto;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @newRecoveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'New recovery code'**
  String get newRecoveryCodeTitle;

  /// No description provided for @newRecoveryCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Your old code will stop working. Enter your password to continue.'**
  String get newRecoveryCodeBody;

  /// No description provided for @createCode.
  ///
  /// In en, this message translates to:
  /// **'Create code'**
  String get createCode;

  /// No description provided for @recoveryHasCode.
  ///
  /// In en, this message translates to:
  /// **'You can reset a forgotten password with your recovery code. Lost it? Create a new one.'**
  String get recoveryHasCode;

  /// No description provided for @recoveryNoCode.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a recovery code yet. Without one, a forgotten password means a lost account.'**
  String get recoveryNoCode;

  /// No description provided for @createNewCode.
  ///
  /// In en, this message translates to:
  /// **'Create a new code'**
  String get createNewCode;

  /// No description provided for @createRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Create a recovery code'**
  String get createRecoveryCode;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes your plans, workouts, weights and photo for good. It can\'t be undone. Enter your password to confirm.'**
  String get deleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted.'**
  String get accountDeleted;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get bodyWeight;

  /// No description provided for @addWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Add your weight so we can estimate the calories you burn.'**
  String get addWeightHint;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, e.g. 78.5'**
  String get enterNumber;

  /// No description provided for @weightRange.
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max} kg'**
  String weightRange(int min, int max);

  /// No description provided for @todaysWeight.
  ///
  /// In en, this message translates to:
  /// **'Today\'s weight'**
  String get todaysWeight;

  /// No description provided for @weightTrendNote.
  ///
  /// In en, this message translates to:
  /// **'We keep every entry, so you can follow the trend.'**
  String get weightTrendNote;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @bioSaved.
  ///
  /// In en, this message translates to:
  /// **'Bio saved'**
  String get bioSaved;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Your goals, your favorite lift, anything…'**
  String get bioHint;

  /// No description provided for @saveBio.
  ///
  /// In en, this message translates to:
  /// **'Save bio'**
  String get saveBio;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @tonnes.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get tonnes;

  /// No description provided for @msPiano.
  ///
  /// In en, this message translates to:
  /// **'a grand piano'**
  String get msPiano;

  /// No description provided for @msPianoPlural.
  ///
  /// In en, this message translates to:
  /// **'grand pianos'**
  String get msPianoPlural;

  /// No description provided for @msCar.
  ///
  /// In en, this message translates to:
  /// **'a small car'**
  String get msCar;

  /// No description provided for @msCarPlural.
  ///
  /// In en, this message translates to:
  /// **'small cars'**
  String get msCarPlural;

  /// No description provided for @msElephant.
  ///
  /// In en, this message translates to:
  /// **'an elephant'**
  String get msElephant;

  /// No description provided for @msElephantPlural.
  ///
  /// In en, this message translates to:
  /// **'elephants'**
  String get msElephantPlural;

  /// No description provided for @msBus.
  ///
  /// In en, this message translates to:
  /// **'a city bus'**
  String get msBus;

  /// No description provided for @msBusPlural.
  ///
  /// In en, this message translates to:
  /// **'city buses'**
  String get msBusPlural;

  /// No description provided for @msTruck.
  ///
  /// In en, this message translates to:
  /// **'a loaded truck'**
  String get msTruck;

  /// No description provided for @msTruckPlural.
  ///
  /// In en, this message translates to:
  /// **'loaded trucks'**
  String get msTruckPlural;

  /// No description provided for @msWhale.
  ///
  /// In en, this message translates to:
  /// **'a blue whale'**
  String get msWhale;

  /// No description provided for @msWhalePlural.
  ///
  /// In en, this message translates to:
  /// **'blue whales'**
  String get msWhalePlural;

  /// No description provided for @msJet.
  ///
  /// In en, this message translates to:
  /// **'a jumbo jet at takeoff'**
  String get msJet;

  /// No description provided for @msJetPlural.
  ///
  /// In en, this message translates to:
  /// **'jumbo jets'**
  String get msJetPlural;

  /// No description provided for @msLondonEye.
  ///
  /// In en, this message translates to:
  /// **'the London Eye'**
  String get msLondonEye;

  /// No description provided for @msLondonEyePlural.
  ///
  /// In en, this message translates to:
  /// **'London Eyes'**
  String get msLondonEyePlural;

  /// No description provided for @msEiffel.
  ///
  /// In en, this message translates to:
  /// **'the Eiffel Tower'**
  String get msEiffel;

  /// No description provided for @msEiffelPlural.
  ///
  /// In en, this message translates to:
  /// **'Eiffel Towers'**
  String get msEiffelPlural;

  /// No description provided for @aboutOne.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String aboutOne(String name);

  /// No description provided for @aboutMany.
  ///
  /// In en, this message translates to:
  /// **'About {count} {name}'**
  String aboutMany(String count, String name);

  /// No description provided for @couldNotLoadProgress.
  ///
  /// In en, this message translates to:
  /// **'Could not load your progress.'**
  String get couldNotLoadProgress;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What your training adds up to.'**
  String get progressSubtitle;

  /// No description provided for @streakNoGoal.
  ///
  /// In en, this message translates to:
  /// **'A week counts when you train at least once. Set a goal to aim higher.'**
  String get streakNoGoal;

  /// No description provided for @streakGoalReached.
  ///
  /// In en, this message translates to:
  /// **'{done} workouts this week, goal of {goal} reached. Nice.'**
  String streakGoalReached(int done, int goal);

  /// No description provided for @streakToGo.
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} this week, {left} to go.'**
  String streakToGo(int done, int goal, int left);

  /// No description provided for @noStreakYet.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get noStreakYet;

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-week streak'**
  String weekStreak(int count);

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get setGoal;

  /// No description provided for @aWeek.
  ///
  /// In en, this message translates to:
  /// **'a week'**
  String get aWeek;

  /// No description provided for @vsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'▲ vs last week'**
  String get vsLastWeek;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @kgLifted.
  ///
  /// In en, this message translates to:
  /// **'Kg lifted'**
  String get kgLifted;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String minutesShort(int minutes);

  /// No description provided for @same.
  ///
  /// In en, this message translates to:
  /// **'same'**
  String get same;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @chooseExercise.
  ///
  /// In en, this message translates to:
  /// **'Choose an exercise'**
  String get chooseExercise;

  /// No description provided for @strengthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finish a workout and your strength trend shows up here.'**
  String get strengthEmpty;

  /// No description provided for @fromLastWorkouts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{From your last workout} other{From your last {count} workouts}}'**
  String fromLastWorkouts(int count);

  /// No description provided for @latestBest.
  ///
  /// In en, this message translates to:
  /// **'Latest workout · best {kg} kg from {set}'**
  String latestBest(String kg, String set);

  /// No description provided for @estimated1rm.
  ///
  /// In en, this message translates to:
  /// **'estimated 1RM'**
  String get estimated1rm;

  /// No description provided for @topSetLabel.
  ///
  /// In en, this message translates to:
  /// **'top set'**
  String get topSetLabel;

  /// No description provided for @bestReps.
  ///
  /// In en, this message translates to:
  /// **'best reps'**
  String get bestReps;

  /// No description provided for @repsUnit.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get repsUnit;

  /// No description provided for @logWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Log your weight to see its trend.'**
  String get logWeightTrend;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get logWeight;

  /// No description provided for @latestWeighIn.
  ///
  /// In en, this message translates to:
  /// **'Latest weigh-in, {when}'**
  String latestWeighIn(String when);

  /// No description provided for @recentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent records'**
  String get recentRecords;

  /// No description provided for @weeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get weeklyVolume;

  /// No description provided for @kgLiftedLower.
  ///
  /// In en, this message translates to:
  /// **'kg lifted'**
  String get kgLiftedLower;

  /// No description provided for @weighIns.
  ///
  /// In en, this message translates to:
  /// **'Weigh-ins'**
  String get weighIns;

  /// No description provided for @logTodaysWeight.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s weight'**
  String get logTodaysWeight;

  /// No description provided for @recordsMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout} other{{count} workouts}} · last {when}'**
  String recordsMeta(int count, String when);

  /// No description provided for @recordHeaviest.
  ///
  /// In en, this message translates to:
  /// **'Heaviest weight'**
  String get recordHeaviest;

  /// No description provided for @recordEstimated1rm.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get recordEstimated1rm;

  /// No description provided for @recordMostReps.
  ///
  /// In en, this message translates to:
  /// **'Most reps'**
  String get recordMostReps;

  /// No description provided for @recordBestSetVolume.
  ///
  /// In en, this message translates to:
  /// **'Best set volume'**
  String get recordBestSetVolume;

  /// No description provided for @finishWithWeights.
  ///
  /// In en, this message translates to:
  /// **'Finish a workout with weights to start'**
  String get finishWithWeights;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @lifetimeVolume.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME VOLUME'**
  String get lifetimeVolume;

  /// No description provided for @nextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String nextMilestone(String name);

  /// No description provided for @toGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String toGo(String amount);

  /// No description provided for @allMilestones.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached. Legendary.'**
  String get allMilestones;

  /// No description provided for @milestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestones;

  /// No description provided for @liftedSoFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} lifted so far'**
  String liftedSoFar(String amount);

  /// No description provided for @milestonesNote.
  ///
  /// In en, this message translates to:
  /// **'Weights are approximate. Volume is reps × weight from finished workouts. Bodyweight sets and cardio aren\'t counted.'**
  String get milestonesNote;

  /// No description provided for @reachedOn.
  ///
  /// In en, this message translates to:
  /// **'Reached {date}'**
  String reachedOn(String date);

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weeklyGoal;

  /// No description provided for @weeklyGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Workouts per week. Hit it and your streak grows.'**
  String get weeklyGoalBody;

  /// No description provided for @noGoal.
  ///
  /// In en, this message translates to:
  /// **'No goal'**
  String get noGoal;

  /// No description provided for @goalPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 workout a week} other{{count} workouts a week}}'**
  String goalPerWeek(int count);

  /// No description provided for @firstTimeWith.
  ///
  /// In en, this message translates to:
  /// **'First time with \"{name}\". Next time you will see how you compare.'**
  String firstTimeWith(String name);

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 personal record} other{{count} personal records}}'**
  String personalRecords(int count);

  /// No description provided for @volumeVsLast.
  ///
  /// In en, this message translates to:
  /// **'Volume vs last {name}'**
  String volumeVsLast(String name);

  /// No description provided for @lastTimeWas.
  ///
  /// In en, this message translates to:
  /// **'Last time was {when}'**
  String lastTimeWas(String when);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @lastLabel.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get lastLabel;

  /// No description provided for @setWeightRepsShort.
  ///
  /// In en, this message translates to:
  /// **'{kg} × {reps}'**
  String setWeightRepsShort(String kg, int reps);

  /// No description provided for @nothingLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet'**
  String get nothingLoggedYet;

  /// No description provided for @oneMoreEntry.
  ///
  /// In en, this message translates to:
  /// **'One more entry and the trend starts here'**
  String get oneMoreEntry;

  /// No description provided for @trendSemantics.
  ///
  /// In en, this message translates to:
  /// **'Trend from {from} to {to} {unit}'**
  String trendSemantics(String from, String to, String unit);

  /// No description provided for @weekBarsSemantics.
  ///
  /// In en, this message translates to:
  /// **'This week {now}, last week {last}'**
  String weekBarsSemantics(String now, String last);

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(String date);

  /// No description provided for @thisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekLabel;

  /// No description provided for @cfSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get cfSpeed;

  /// No description provided for @cfIncline.
  ///
  /// In en, this message translates to:
  /// **'Incline'**
  String get cfIncline;

  /// No description provided for @cfDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cfDistance;

  /// No description provided for @cfLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get cfLevel;

  /// No description provided for @cfDamper.
  ///
  /// In en, this message translates to:
  /// **'Damper'**
  String get cfDamper;

  /// No description provided for @cfFloors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get cfFloors;

  /// No description provided for @cfCadence.
  ///
  /// In en, this message translates to:
  /// **'Cadence'**
  String get cfCadence;

  /// No description provided for @cfStrokeRate.
  ///
  /// In en, this message translates to:
  /// **'Stroke rate'**
  String get cfStrokeRate;

  /// No description provided for @cfPoolLength.
  ///
  /// In en, this message translates to:
  /// **'Pool length'**
  String get cfPoolLength;

  /// No description provided for @cfLaps.
  ///
  /// In en, this message translates to:
  /// **'Laps'**
  String get cfLaps;

  /// No description provided for @unitKmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get unitKmh;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitM;

  /// No description provided for @cardioRange.
  ///
  /// In en, this message translates to:
  /// **'{label}: {min} to {max}{unit}'**
  String cardioRange(String label, String min, String max, String unit);

  /// No description provided for @cmTreadmill.
  ///
  /// In en, this message translates to:
  /// **'Treadmill'**
  String get cmTreadmill;

  /// No description provided for @cmStairs.
  ///
  /// In en, this message translates to:
  /// **'Stairs'**
  String get cmStairs;

  /// No description provided for @cmBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get cmBike;

  /// No description provided for @cmElliptical.
  ///
  /// In en, this message translates to:
  /// **'Elliptical'**
  String get cmElliptical;

  /// No description provided for @cmRower.
  ///
  /// In en, this message translates to:
  /// **'Rower'**
  String get cmRower;

  /// No description provided for @cmSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get cmSwimming;

  /// No description provided for @cmOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cmOther;

  /// No description provided for @whyIncrease.
  ///
  /// In en, this message translates to:
  /// **'you hit every rep last time'**
  String get whyIncrease;

  /// No description provided for @whyRepeat.
  ///
  /// In en, this message translates to:
  /// **'same weight, beat the reps'**
  String get whyRepeat;

  /// No description provided for @whyDeload.
  ///
  /// In en, this message translates to:
  /// **'lighter to recover after two tough workouts'**
  String get whyDeload;

  /// No description provided for @whyMoreReps.
  ///
  /// In en, this message translates to:
  /// **'one more rep than your best'**
  String get whyMoreReps;

  /// No description provided for @cdSpeed.
  ///
  /// In en, this message translates to:
  /// **'{value} km/h'**
  String cdSpeed(String value);

  /// No description provided for @cdIncline.
  ///
  /// In en, this message translates to:
  /// **'{value}% incline'**
  String cdIncline(String value);

  /// No description provided for @cdKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String cdKm(String value);

  /// No description provided for @cdMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String cdMeters(int value);

  /// No description provided for @cdDamper.
  ///
  /// In en, this message translates to:
  /// **'Damper {value}'**
  String cdDamper(int value);

  /// No description provided for @cdLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {value}'**
  String cdLevel(int value);

  /// No description provided for @cdFloors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 floor} other{{count} floors}}'**
  String cdFloors(int count);

  /// No description provided for @cdLapsOf.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lap of {pool} m} other{{count} laps of {pool} m}}'**
  String cdLapsOf(int count, int pool);

  /// No description provided for @cdLaps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lap} other{{count} laps}}'**
  String cdLaps(int count);

  /// No description provided for @cdPool.
  ///
  /// In en, this message translates to:
  /// **'{value} m pool'**
  String cdPool(int value);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @durationRange.
  ///
  /// In en, this message translates to:
  /// **'Duration: 1 to 300 minutes'**
  String get durationRange;

  /// No description provided for @addCardio.
  ///
  /// In en, this message translates to:
  /// **'Add cardio'**
  String get addCardio;

  /// No description provided for @howLong.
  ///
  /// In en, this message translates to:
  /// **'How long?'**
  String get howLong;

  /// No description provided for @minUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minUnit;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details (optional)'**
  String get moreDetails;

  /// No description provided for @swimDistanceNote.
  ///
  /// In en, this message translates to:
  /// **'Laps and pool length are enough: the distance is worked out for you.'**
  String get swimDistanceNote;

  /// No description provided for @caloriesRough.
  ///
  /// In en, this message translates to:
  /// **'Calories are a rough estimate.'**
  String get caloriesRough;

  /// No description provided for @caloriesRoughMachine.
  ///
  /// In en, this message translates to:
  /// **'Calories are a rough estimate, since machines measure effort differently.'**
  String get caloriesRoughMachine;

  /// No description provided for @addWeightForCalories.
  ///
  /// In en, this message translates to:
  /// **'Add your weight in Profile to see the calories you burn.'**
  String get addWeightForCalories;

  /// No description provided for @finishWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish workout?'**
  String get finishWorkoutTitle;

  /// No description provided for @finishAllDone.
  ///
  /// In en, this message translates to:
  /// **'Nice, you did everything you planned.'**
  String get finishAllDone;

  /// No description provided for @finishUnfinished.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise is not complete. You can still finish, what you logged is saved.} other{{count} exercises are not complete. You can still finish, what you logged is saved.}}'**
  String finishUnfinished(int count);

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @howDidItFeel.
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get howDidItFeel;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get finishWorkout;

  /// No description provided for @keepTraining.
  ///
  /// In en, this message translates to:
  /// **'Keep training'**
  String get keepTraining;

  /// No description provided for @addedToPlan.
  ///
  /// In en, this message translates to:
  /// **'Added {what} to {name}'**
  String addedToPlan(String what, String name);

  /// No description provided for @addToPlanQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}?'**
  String addToPlanQuestion(String name);

  /// No description provided for @planAdditionsBody.
  ///
  /// In en, this message translates to:
  /// **'You added these during this workout. Choose which to keep in your plan.'**
  String get planAdditionsBody;

  /// No description provided for @addCountToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add {count} to plan'**
  String addCountToPlan(int count);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @addName.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addName(String name);

  /// No description provided for @targetForSemantics.
  ///
  /// In en, this message translates to:
  /// **'Target for {name}: {target}. Tap to change.'**
  String targetForSemantics(String name, String target);

  /// No description provided for @discardWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard workout?'**
  String get discardWorkoutTitle;

  /// No description provided for @discardWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you logged in this workout will be deleted.'**
  String get discardWorkoutBody;

  /// No description provided for @keepGoingButton.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoingButton;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @noCardioToday.
  ///
  /// In en, this message translates to:
  /// **'No cardio today?'**
  String get noCardioToday;

  /// No description provided for @cardioReminderBody.
  ///
  /// In en, this message translates to:
  /// **'A few minutes of cardio is a good way to finish. It is up to you.'**
  String get cardioReminderBody;

  /// No description provided for @finishWithoutCardio.
  ///
  /// In en, this message translates to:
  /// **'Finish without cardio'**
  String get finishWithoutCardio;

  /// No description provided for @logSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Log at least one set or some cardio first, or discard the workout.'**
  String get logSomethingFirst;

  /// No description provided for @couldNotLoadSession.
  ///
  /// In en, this message translates to:
  /// **'Could not load your workout.'**
  String get couldNotLoadSession;

  /// No description provided for @noWorkoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'No workout in progress'**
  String get noWorkoutInProgress;

  /// No description provided for @noWorkoutInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Start one from a plan, or a quick workout.'**
  String get noWorkoutInProgressBody;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @minimise.
  ///
  /// In en, this message translates to:
  /// **'Minimise'**
  String get minimise;

  /// No description provided for @discardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard workout'**
  String get discardWorkout;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @doneOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} OF {total} DONE'**
  String doneOfTotal(int done, int total);

  /// No description provided for @quickWorkoutOverline.
  ///
  /// In en, this message translates to:
  /// **'QUICK WORKOUT'**
  String get quickWorkoutOverline;

  /// No description provided for @whatTraining.
  ///
  /// In en, this message translates to:
  /// **'What are you training?'**
  String get whatTraining;

  /// No description provided for @quickWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Add exercises as you go, or just log some cardio.'**
  String get quickWorkoutBody;

  /// No description provided for @setsLoggedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{logged} / {target} sets'**
  String setsLoggedOfTarget(int logged, int target);

  /// No description provided for @exerciseRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'{number}. {name}, {progress}{done}{active}. Tap to open.'**
  String exerciseRowSemantics(
    int number,
    String name,
    String progress,
    String done,
    String active,
  );

  /// No description provided for @semDone.
  ///
  /// In en, this message translates to:
  /// **', done'**
  String get semDone;

  /// No description provided for @semDoThisNow.
  ///
  /// In en, this message translates to:
  /// **', do this now'**
  String get semDoThisNow;

  /// No description provided for @progressWithTarget.
  ///
  /// In en, this message translates to:
  /// **'{progress} · target {sets} × {reps}'**
  String progressWithTarget(String progress, int sets, int reps);

  /// No description provided for @cardioFinishPrompt.
  ///
  /// In en, this message translates to:
  /// **'Finish with some cardio? Pick the machine and how long.'**
  String get cardioFinishPrompt;

  /// No description provided for @noKcal.
  ///
  /// In en, this message translates to:
  /// **'— kcal'**
  String get noKcal;

  /// No description provided for @deleteCardio.
  ///
  /// In en, this message translates to:
  /// **'Delete cardio'**
  String get deleteCardio;

  /// No description provided for @workoutInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get workoutInProgressTitle;

  /// No description provided for @workoutInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'You have \"{name}\" running. Finish or cancel it before starting a new one.'**
  String workoutInProgressBody(String name);

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @caloriesEstimated.
  ///
  /// In en, this message translates to:
  /// **'Calories (estimated)'**
  String get caloriesEstimated;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @addWeightInProfile.
  ///
  /// In en, this message translates to:
  /// **'Add weight in Profile'**
  String get addWeightInProfile;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get workoutComplete;

  /// No description provided for @thisWorkoutCompare.
  ///
  /// In en, this message translates to:
  /// **'This workout: {comparison}'**
  String thisWorkoutCompare(String comparison);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @newMilestone.
  ///
  /// In en, this message translates to:
  /// **'NEW MILESTONE'**
  String get newMilestone;

  /// No description provided for @youLifted.
  ///
  /// In en, this message translates to:
  /// **'You\'ve lifted {name}'**
  String youLifted(String name);

  /// No description provided for @totalPassed.
  ///
  /// In en, this message translates to:
  /// **'Your total passed {amount}, about the weight of {name}'**
  String totalPassed(String amount, String name);

  /// No description provided for @passedOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'And passed {names} on the way'**
  String passedOnTheWay(String names);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @removeExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise?'**
  String get removeExerciseTitle;

  /// No description provided for @removeExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The 1 logged set of this exercise will be deleted.} other{The {count} logged sets of this exercise will be deleted.}}'**
  String removeExerciseBody(int count);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @targetSetsReps.
  ///
  /// In en, this message translates to:
  /// **'Target {sets} × {reps}'**
  String targetSetsReps(int sets, int reps);

  /// No description provided for @closeName.
  ///
  /// In en, this message translates to:
  /// **'Close {name}'**
  String closeName(String name);

  /// No description provided for @exerciseOptions.
  ///
  /// In en, this message translates to:
  /// **'Exercise options'**
  String get exerciseOptions;

  /// No description provided for @removeFromWorkout.
  ///
  /// In en, this message translates to:
  /// **'Remove from workout'**
  String get removeFromWorkout;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSet;

  /// No description provided for @nextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get nextExercise;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get now;

  /// No description provided for @restChipSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rest {time} between sets. Tap to change.'**
  String restChipSemantics(String time);

  /// No description provided for @restChip.
  ///
  /// In en, this message translates to:
  /// **'Rest {time}'**
  String restChip(String time);

  /// No description provided for @suggestedToday.
  ///
  /// In en, this message translates to:
  /// **'Suggested today: {target}, {why}'**
  String suggestedToday(String target, String why);

  /// No description provided for @todayPrefix.
  ///
  /// In en, this message translates to:
  /// **'Today  '**
  String get todayPrefix;

  /// No description provided for @firstTimeExercise.
  ///
  /// In en, this message translates to:
  /// **'First time doing this one. Today sets your baseline.'**
  String get firstTimeExercise;

  /// No description provided for @lastTimeWhen.
  ///
  /// In en, this message translates to:
  /// **'Last time · {when}'**
  String lastTimeWhen(String when);

  /// No description provided for @bodyweightShort.
  ///
  /// In en, this message translates to:
  /// **'BW'**
  String get bodyweightShort;

  /// No description provided for @restSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Rest after each set, for this workout. Your plan stays as it is.'**
  String get restSheetBody;

  /// No description provided for @restDone.
  ///
  /// In en, this message translates to:
  /// **'REST DONE'**
  String get restDone;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get rest;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get go;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(int number);

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @emptyIsBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Empty = bodyweight'**
  String get emptyIsBodyweight;

  /// No description provided for @deleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get deleteSet;

  /// No description provided for @repsRange.
  ///
  /// In en, this message translates to:
  /// **'Reps: 1 to {max}'**
  String repsRange(int max);

  /// No description provided for @weightRangeSet.
  ///
  /// In en, this message translates to:
  /// **'Weight: 0 to {max} kg'**
  String weightRangeSet(String max);

  /// No description provided for @colSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get colSet;

  /// No description provided for @colKg.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get colKg;

  /// No description provided for @colReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get colReps;

  /// No description provided for @setDoneSemantics.
  ///
  /// In en, this message translates to:
  /// **'Set {number}: {weight}, {reps} reps, done. Tap to edit.'**
  String setDoneSemantics(int number, String weight, int reps);

  /// No description provided for @semBodyweight.
  ///
  /// In en, this message translates to:
  /// **'bodyweight'**
  String get semBodyweight;

  /// No description provided for @semKilograms.
  ///
  /// In en, this message translates to:
  /// **'{kg} kilograms'**
  String semKilograms(String kg);

  /// No description provided for @setWeightSemantics.
  ///
  /// In en, this message translates to:
  /// **'Set {number} weight in kilograms'**
  String setWeightSemantics(int number);

  /// No description provided for @setRepsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Set {number} reps'**
  String setRepsSemantics(int number);

  /// No description provided for @logSetNumber.
  ///
  /// In en, this message translates to:
  /// **'Log set {number}'**
  String logSetNumber(int number);

  /// No description provided for @nextSetLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} · set {number}'**
  String nextSetLabel(String name, int number);

  /// No description provided for @restOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest is over'**
  String get restOverTitle;

  /// No description provided for @restingTitle.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get restingTitle;

  /// No description provided for @timeNextExercise.
  ///
  /// In en, this message translates to:
  /// **'Time for your next exercise'**
  String get timeNextExercise;

  /// No description provided for @timeNextSet.
  ///
  /// In en, this message translates to:
  /// **'Time for your next set'**
  String get timeNextSet;

  /// No description provided for @nextColon.
  ///
  /// In en, this message translates to:
  /// **'Next: {what}'**
  String nextColon(String what);

  /// No description provided for @logValues.
  ///
  /// In en, this message translates to:
  /// **'Log {values}'**
  String logValues(String values);

  /// No description provided for @channelRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get channelRestTimer;

  /// No description provided for @channelRestTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Tells you when your rest between sets is over.'**
  String get channelRestTimerDesc;

  /// No description provided for @channelRestCountdown.
  ///
  /// In en, this message translates to:
  /// **'Rest countdown'**
  String get channelRestCountdown;

  /// No description provided for @channelRestCountdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows the rest counting down while you are outside the app.'**
  String get channelRestCountdownDesc;

  /// No description provided for @skipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get skipRest;

  /// No description provided for @logSet.
  ///
  /// In en, this message translates to:
  /// **'Log set'**
  String get logSet;

  /// No description provided for @restAdd15.
  ///
  /// In en, this message translates to:
  /// **'{value}s'**
  String restAdd15(String value);

  /// No description provided for @restAdd15Notification.
  ///
  /// In en, this message translates to:
  /// **'{value} s'**
  String restAdd15Notification(String value);

  /// No description provided for @gainReps.
  ///
  /// In en, this message translates to:
  /// **'{value} reps'**
  String gainReps(String value);

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get switchLanguage;

  /// Exercise details sheet (Phase 11C): heading of a row of chips
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentLabel;

  /// Exercise details sheet (Phase 11C): heading of a row of chips
  ///
  /// In en, this message translates to:
  /// **'Main muscle'**
  String get targetMusclesLabel;

  /// Exercise details sheet (Phase 11C): heading of a row of chips
  ///
  /// In en, this message translates to:
  /// **'Also works'**
  String get secondaryMusclesLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
