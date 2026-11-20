# Testing FitPlan on a real phone (free)

## 1. The server
Test builds talk to the **Dev** API on Azure, `https://fitplan-api-dev.azurewebsites.net`, so they work on any network. Production (`https://fitplan-api-eyad.azurewebsites.net`) runs an older version until the launch release, so don't point test builds at it. See [DEPLOYMENT.md](DEPLOYMENT.md) for details.

The Dev database pauses when idle. The first request after a long break can take up to a minute or fail once; try again before reporting it.

To test against the API on your own PC instead, run it with `dotnet run --project Backend/FitPlan.Api --launch-profile lan` and build the app with `API_BASE_URL=http://<your PC IP>:5264`. The phone and the PC must be on the same Wi-Fi.

## 2. iPhone: build the app on Codemagic
1. Sign up at [codemagic.io](https://codemagic.io) with GitHub and pick the `FitPlan` repository.
2. Codemagic reads `codemagic.yaml` automatically. Choose the **iPhone test build (unsigned)** workflow and the `develop` branch.
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
flutter build apk --release --dart-define=API_BASE_URL=https://fitplan-api-dev.azurewebsites.net
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

## 6. Phases 5–8 checklist (one build)
Use a new account made on the phone for this test, and delete it at the end (step 5.9).

**Note on the first open:** an older build installed over this one still holds a Production login. Dev refuses it, so the app should ask you to log in **once**, with no crash and no loop. That is the expected result.

**Phase 5: sessions, account security and profile**
- [ ] 5.1 Register. A recovery code (XXXX-XXXX-XXXX-XXXX) appears. Write it down.
- [ ] 5.2 Wrong password: a clear "wrong password" message, not a server error.
- [ ] 5.3 Many wrong logins in one minute: "Too many attempts. Wait a minute and try again."
- [ ] 5.4 A workout longer than 35 minutes (do it together with Phase 7): you are never logged out.
- [ ] 5.5 Airplane mode for a minute during the workout: you stay logged in, a connection message appears, and it works again when you turn airplane mode off.
- [ ] 5.6 Leave the app for more than 35 minutes, restart the phone, open the app: still logged in.
- [ ] 5.7 Profile picture: tap the avatar for a full-screen preview (pinch and double-tap zoom). Change it from the camera badge, with the camera and with photos.
- [ ] 5.8 Log out, then "Forgot password?" with the recovery code (lower case with spaces also works): signed in, and a new code is shown. From the profile, make another new code (asks for the password).
- [ ] 5.9 At the very end: Delete account with a wrong password (error, still signed in), then with the right one (back to login; logging in again fails).

**Phase 6: exercise library**
- [ ] 6.1 Browse exercises from the search button on Plans, without a plan. Browsing creates no plan.
- [ ] 6.2 No cardio body part in the chips, and searching "treadmill" or "bike" finds no cardio exercises.
- [ ] 6.3 GIFs load on Wi-Fi and on mobile data. A missing one shows "Demo not available" with the instructions still visible.
- [ ] 6.4 Add an exercise from the library to a new plan and to an existing plan. Adding the same one again is refused.

**Phase 7: workout session**
- [ ] 7.1 In a plan, set rest to 45 s on one exercise and leave another on the default (90 s).
- [ ] 7.2 Start that plan: exercises stay in plan order, one card is open, and "NOW" marks the active exercise without moving it.
- [ ] 7.3 Type reps and weight, collapse the card, reopen it: the typed values are still there.
- [ ] 7.4 Logging the last target set closes the card, opens the next unfinished one, and the rest countdown uses that exercise's rest.
- [ ] 7.5 Change rest from the "Rest" chip during the workout. The plan's rest stays the same.
- [ ] 7.6 During a rest countdown, send the app to the background, then force-close it and reopen it: the workout and the remaining rest time come back. (No notification yet; that is Phase 9.)
- [ ] 7.7 Add an exercise that isn't in the plan and log sets for it.
- [ ] 7.8 Finish without cardio: the cardio reminder appears first, then the finish sheet, then the question about adding the new exercise to the plan. Decline once (plan unchanged); in another workout, accept (the exercise is added with sensible targets).

**Phase 8: cardio**
- [ ] 8.1 The machine picker shows six machines, including Swimming and no Other.
- [ ] 8.2 Each machine shows only its own fields under "More details" (Stairs: level and floors, no speed).
- [ ] 8.3 Save a Stairs entry and a Swimming entry with laps and pool length only: the distance is filled in, and calories are labelled as rough.
- [ ] 8.4 History and the workout details show each machine's own details (for example "Level 8 · 45 floors").

**For every problem, report:** the step number, a screenshot, and the approximate time, so it can be matched with the Dev logs.
