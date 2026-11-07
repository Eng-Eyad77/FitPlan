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
- The `Backend build and tests` and `Flutter analyze and tests` checks must pass before merging.

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

## Dev deployment

Every merge into `develop` runs `.github/workflows/deploy-dev.yml`: the CI checks, then a deploy to `fitplan-api-dev`, then these checks:

- `/health/live` reports the commit that was just merged. This check doesn't touch the database.
- `/swagger/index.html` returns 404, and `/api/profile/me` returns 401 without a token.
- `/api/exercises` returns 200, which proves the API reads the Dev database through Managed Identity.

The deploy identity can only reach the Dev web app. It has no database access and can't change SQL firewall rules.

The workflow signs in to Azure with OpenID Connect, so no Azure password or key is stored in GitHub. The identity's federated credential trusts one subject only:

```text
repo:Eng-Eyad77@177796235/FitPlan@1408724659:environment:dev
```

GitHub sends this immutable format for repositories created after July 15, 2026. The numbers are the account and repository IDs, which don't change if either is renamed. If sign-in fails with `AADSTS700213`, compare the subject in the error with the federated credential. Any new environment, such as Production, needs a credential in the same format.

### If a deploy fails

The run turns red, and nothing rolls back or deploys an older version by itself. Check the failed step and the App Service logs, then decide. To go back, open a pull request that reverts the bad commit, which goes through the same checks and deploy. Undoing a schema change is a separate decision with its own plan.

### Schema changes

Each deploy compares `Backend/FitPlan.Api/Migrations` between the commit that `/health/live` reports on Dev and the commit being deployed. It continues by itself only if that comparison completes with no difference. In every other case, it waits for approval at the `dev-schema` environment:

- The migrations differ.
- `/health/live` doesn't answer, or doesn't report a valid commit.
- The running commit isn't in the repository, or the comparison fails.

**Approval is a person's decision, not technical proof.** GitHub only records that someone approved. It can't tell whether a migration script ran, because the workflow has no database access. Before you approve, check the evidence yourself.

**Don't merge a migration yet.** Migrations are applied with the `FitPlan.Migrator` tool, which doesn't exist yet. A schema change has to wait until it does.

The tool will apply a generated SQL script as `fitplan-migrator`, which has only `db_ddladmin`, `db_datareader` and `db_datawriter`. The rules for running a script are:

- Review the script, which must stay compatible with the running API, and approve its SHA-256.
- Reject any script that fails validation or differs from the expected EF Core format.
- Use one unpooled connection with `SET XACT_ABORT ON`, and `EXECUTE AS USER ... WITH COOKIE`, with `REVERT WITH COOKIE` in cleanup.
- Stop at the first error. `XACT_ABORT` doesn't catch every failure: after `RAISERROR`, the migration can still commit and record itself as applied.
- Never retry a migration whose result is uncertain. Compare the schema with a reference database first.
- If permissions aren't enough, stop and report the exact error. Don't add `db_owner`.

If the run waits for another reason, find out why before you approve. The first deploy of `/health/live` waits this way, because the running API doesn't have that endpoint yet. To stop a deploy, reject the run. GitHub lets a run wait up to 30 days for approval.

### Environment settings

| Setting | `dev` | `dev-schema` |
| --- | --- | --- |
| Deployment branches | `develop` only | `develop` only |
| Required reviewer | None | `Eng-Eyad77` |
| Prevent self-review | Not applicable | Off, because there's one reviewer |
| Allow administrators to bypass | Off | Off |
| Secrets | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` | None |

Create both before any workflow references them, because GitHub creates a missing environment with no protection. Each deploy stops if `dev-schema` has no required reviewer.

### Temporary SQL firewall rules

Name a temporary rule `temp-migrate-YYYYMMDDTHHMMZ`, with its UTC start time, and limit it to one IP. Aim to delete it within 30 minutes. After 60 minutes, it counts as abandoned.

Azure emails `fitplan-free-tier-alerts` on every firewall rule change on `fitplan-sql-eyad-dev`. Before each migration, at the start of Azure work, and before each phase report, list the rules and look for any that doesn't start with `dev-app-out-`:

```bash
az sql server firewall-rule list -g fitplan-dev-rg -s fitplan-sql-eyad-dev -o table
```

To recover an abandoned rule:

1. Confirm that the name matches `temp-migrate-*`, that it's more than 60 minutes old, and that no migration is running.
2. Delete it by its exact name, or use the Azure portal: `fitplan-sql-eyad-dev`, then **Networking**.

   ```bash
   az sql server firewall-rule delete -g fitplan-dev-rg -s fitplan-sql-eyad-dev -n temp-migrate-YYYYMMDDTHHMMZ
   ```

3. List the rules again, and confirm that only the `dev-app-out-*` rules remain.
4. If a migration was interrupted, check `__EFMigrationsHistory` before running it again.

Don't delete a rule with any other name. Check who created it in the Azure activity log first. Never change a `dev-app-out-*` rule as part of this procedure.

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
