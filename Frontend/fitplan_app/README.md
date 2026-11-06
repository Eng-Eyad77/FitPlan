# FitPlan app

The FitPlan mobile app: plan workouts, log every set, and track progress. Built with Flutter, for iOS and Android.

The app talks to the ASP.NET Core API in `Backend/FitPlan.Api`.

## Stack

- **State:** Riverpod
- **Navigation:** go_router
- **Network:** dio
- **Models:** freezed and json_serializable
- **Token storage:** flutter_secure_storage
- **Charts:** fl_chart
- **Font:** Readex Pro

## Run

From this folder:

```bash
flutter pub get
flutter run
```

By default, the app connects to the API running on your PC: `http://localhost:5264`, or `http://10.0.2.2:5264` from the Android emulator.

To use another API, or to run on a physical phone, set `API_BASE_URL`:

```bash
flutter run --dart-define=API_BASE_URL=http://<your PC IP>:5264
```

## Check your changes

```bash
flutter analyze
flutter test
```

## Generated code

The `*.freezed.dart` and `*.g.dart` files are committed, because the iOS builds have no `build_runner` step. After changing a model, regenerate them and commit the result:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## App icons

The source images are in `assets/icon/`. To regenerate the platform icons:

```bash
dart run flutter_launcher_icons
```

## More documentation

- [Testing on a real phone](../../docs/TESTING_ON_DEVICES.md)
- [Git workflow](../../docs/WORKFLOW.md)
