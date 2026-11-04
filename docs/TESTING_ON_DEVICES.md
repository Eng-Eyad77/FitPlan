# Testing FitPlan on a real phone (free)

## 1. The server
The app talks to the API on Azure, `https://fitplan-api-eyad.azurewebsites.net`, so it works on any network. See [DEPLOYMENT.md](DEPLOYMENT.md) for details.

To test against the API on your own PC instead, run it with `dotnet run --project Backend/FitPlan.Api --launch-profile lan` and build the app with `API_BASE_URL=http://<your PC IP>:5264`. The phone and the PC must be on the same Wi-Fi.

## 2. iPhone: build the app on Codemagic
1. Sign up at [codemagic.io](https://codemagic.io) with GitHub and pick the `FitPlan` repository.
2. Codemagic reads `codemagic.yaml` automatically. Choose the **iPhone test build (unsigned)** workflow.
3. Press **Start build** (about 5–10 minutes). When it finishes, download **FitPlan-test.ipa** from Artifacts.

If Codemagic stays queued for a long time, the same build can run on GitHub Actions: **Actions → iPhone test build → Run workflow** (`.github/workflows/ios-test.yml`).

## 3. iPhone: install with Sideloadly (on Windows)
1. Install **iTunes** from Apple's website (not the Microsoft Store version) and **Sideloadly** from its official site, `sideloadly.io`.
2. Connect the iPhone with a cable and tap **Trust** on the phone.
3. Drop the `.ipa` onto Sideloadly, enter an Apple ID and press **Start**.
   - Use a **secondary Apple ID** for testing, not your main one.
4. On the iPhone:
   - **Settings → Privacy & Security → Developer Mode**: turn it on; the phone restarts (iOS 16 and later).
   - **Settings → General → VPN & Device Management** → pick the Apple ID → **Trust**.
5. Open FitPlan.

**Limits:** with a free Apple ID the app runs for **7 days**; after that repeat step 3 (about a minute). At most 3 apps can be installed this way.

## 4. Android: an APK for any Android phone
```
cd Frontend/fitplan_app
flutter build apk --release --dart-define=API_BASE_URL=https://fitplan-api-eyad.azurewebsites.net
```
The file is `Frontend/fitplan_app/build/app/outputs/flutter-apk/app-release.apk`. Send it to the tester; when installing, the phone asks to allow installs from an unknown source.

## 5. Test checklist
- [ ] Register, log out, log in, and a wrong password
- [ ] Profile picture from the **camera** and from **photos** (the permission prompts appear)
- [ ] Add body weight, and set the weekly goal
- [ ] New plan: add exercises, edit targets, reorder by dragging, remove an exercise
- [ ] Exercise search, GIFs load, exercise details
- [ ] A full workout: sets, edit a set, delete a set, rest timer (+15s and Skip), cardio, finish
- [ ] **Force-close the app in the middle of a workout and reopen it**: it must return to the workout
- [ ] A second workout from the same plan: the 💡 suggestion, PRs and the comparison
- [ ] History: details and delete
- [ ] Progress: the charts, and tapping them shows the values
- [ ] The keyboard never covers fields, and no text is cut off
- [ ] **iPhone only:** the notch and home indicator don't cover buttons, and swipe back works

Report any problem with a screenshot.
