# Git workflow

GitHub is the source of truth. Work happens locally on a feature branch and reaches the shared branches only through a pull request.

## Branches

| Branch | Purpose | Rules |
| --- | --- | --- |
| `main` | Released code. Will deploy to Production from Phase 3, after manual approval. | Protected |
| `develop` | Integration branch. Will deploy to Dev from Phase 3. | Protected |
| `feature/<short-name>` | One piece of work, branched from `develop`. | Deleted after merging |
| `hotfix/<short-name>` | An urgent Production fix, branched from `main`. | Deleted after merging |

```text
feature/* ── PR ──► develop ── PR ──► main
hotfix/*  ── PR ──► main ── PR ──► develop
```

## Protection rules

These apply to `main` and `develop`, including for repository admins:

- Pull requests are required, so direct pushes are refused.
- Force pushes are blocked.
- Branch deletion is blocked.
- Required approvals are set to 0, because GitHub doesn't let a solo developer approve their own pull request.
- Required status checks start in Phase 3, when the repository has CI.

## Daily work

### 1. Start a feature

```bash
git switch develop
```

```bash
git pull origin develop
```

```bash
git switch -c feature/short-name
```

### 2. Check your changes

From `Frontend/fitplan_app`:

```bash
flutter analyze
```

```bash
flutter test
```

From `Backend`:

```bash
dotnet test FitPlan.slnx
```

This builds the API and runs its tests. They need a SQL Server on your machine, SQL Express by default. Each run creates its own `FitPlanTests_*` databases and drops them afterwards. To use another local server, set `FITPLAN_TEST_SQL` to its connection string. The tests refuse any server that isn't on this machine.

Every pull request into `develop` or `main` runs the same checks in GitHub Actions (`.github/workflows/ci.yml`), using a throwaway SQL Server container. CI doesn't sign in to Azure, deploy anything or build a mobile app. Managed Identity sign-in can't be tested there, so it's checked on the Dev API.

### 3. Commit

Name the files you are staging, and read the staged diff before committing:

```bash
git add path/to/file1 path/to/file2
```

```bash
git diff --staged
```

```bash
git commit -m "Describe what changed and why"
```

Don't use `git add .`, because it can pick up files you didn't mean to share.

### 4. Open a pull request

```bash
git push -u origin feature/short-name
```

Then open the pull request in the browser. The base branch is the first name in the URL:

```text
https://github.com/Eng-Eyad77/FitPlan/compare/develop...feature/short-name
```

Merge with **Squash and merge**.

### 5. Clean up

```bash
git switch develop
```

```bash
git pull origin develop
```

```bash
git branch -d feature/short-name
```

If `git branch -d` refuses after a squash merge, confirm the pull request was merged on GitHub, then use `git branch -D feature/short-name`.

## Release

Open a pull request from `develop` to `main`, and merge with **Create a merge commit**:

```text
https://github.com/Eng-Eyad77/FitPlan/compare/main...develop
```

Merging to `main` must not reach Production until the approved pipeline exists. Until Phase 3 there is no automatic deployment, and any Production change needs explicit approval.

## Hotfix

```bash
git switch main
```

```bash
git pull origin main
```

```bash
git switch -c hotfix/short-name
```

Open a pull request to `main`. After it merges, open a pull request from `main` to `develop`, using **Create a merge commit**, so the fix isn't lost:

```text
https://github.com/Eng-Eyad77/FitPlan/compare/develop...main
```

## App builds

Decision D16 sets how iOS and Android app builds run:

- **iOS:** manual Codemagic builds only, when a new build is needed for testing or installation.
- **Android:** local builds on the development machine, when a new build is needed.
- **Automatic builds:** none. A Git push or pull request never starts an iOS or Android build.
- **Backend-only changes:** these don't need an iOS build.
- **Signing:** changes to code signing, certificates, provisioning profiles or Apple Developer account settings need Eyad's explicit approval.

This covers iOS and Android app builds only. API builds in CI and Admin Web builds in GitHub Actions are separate.

### iOS: Codemagic

1. Open the app on codemagic.io and press **Start new build**.
2. Choose the branch to build.
3. Choose the **iPhone test build (unsigned)** workflow.

### Android: local

From `Frontend/fitplan_app`:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://fitplan-api-eyad.azurewebsites.net
```

The APK is saved to `build/app/outputs/flutter-apk/app-release.apk`. Git ignores it, so never add it to a commit.

### Which API a build uses

`API_BASE_URL` in `codemagic.yaml` and in the Android command above points to the Production API, so these test builds use real data. This changes when Dev exists in Phase 2.

## Never commit

Secrets, connection strings, signing keys, local databases, build output, or machine-specific settings. The root `.gitignore` covers the common cases, but it only catches file names, so still read the diff.

If a secret is committed, treat it as exposed even after you remove it. Rotate it, because Git history keeps the old value.
