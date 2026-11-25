# FitPlan Admin

The admin dashboard, Flutter Web (Phase 12). It shares its look with the phone app through
`../fitplan_shared`, and none of its code ships in the phone app.

Run it against a local API (`http://localhost:5264`):

```
flutter run -d chrome
```

Against the Dev API (D10: on Dev the admin only runs on your machine):

```
flutter run -d chrome --dart-define=API_BASE_URL=https://fitplan-api-dev.azurewebsites.net --dart-define=ADMIN_ENV=Dev
```

An admin is made only with `FitPlan.Migrator make-owner`, never from the app.
