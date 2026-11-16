# Deploying the API to Azure

Every deploy runs from GitHub Actions. Nobody uploads a ZIP by hand. [WORKFLOW.md](WORKFLOW.md) has the full steps, approvals and rollback.

| Environment | URL | Deployed by |
| --- | --- | --- |
| Dev | https://fitplan-api-dev.azurewebsites.net | Every merge into `develop`, through `deploy-dev.yml` |
| Production | https://fitplan-api-eyad.azurewebsites.net | Every merge into `main`, through `deploy-prod.yml`, after your approval |

Subscription: Azure for Students. Region: UAE North.

## Resources

| Resource | Dev (`fitplan-dev-rg`) | Production (`fitplan-rg`) |
| --- | --- | --- |
| App Service plan | `fitplan-plan-dev`, F1 Linux (free) | `fitplan-plan`, F1 Linux (free) |
| Web app | `fitplan-api-dev`, .NET 10 | `fitplan-api-eyad`, .NET 10 |
| SQL server | `fitplan-sql-eyad-dev`, Microsoft Entra authentication only | `fitplan-sql-eyad`. The admin login is kept with the other secrets, not in this file. |
| Database | `FitPlanDb-dev`, free offer | `FitPlanDb`, free offer |
| Deploy identity | `fitplan-gh-dev` | `fitplan-gh-prod` |

Both databases are serverless and pause when idle or when the monthly free limit is used up.

## Settings (in Azure, not in the code)

- **Connection string:** `FitPlanDb`. Dev signs in with its managed identity. Production still uses a SQL login.
- **App settings:**
  - `Jwt__Key`
  - `ASPNETCORE_ENVIRONMENT`: `Dev` or `Production`
  - `Uploads__Root=/home/data/uploads`: profile pictures are saved here so they survive deploys.

Secret values live **only** in the Azure settings and in a local file outside the repository. Never commit them. The deploy identities can't read them.

## Deploying a new version

1. Merge a pull request into `develop`. Dev deploys by itself and runs its checks.
2. Open a release pull request from `develop` to `main` and merge it with a merge commit.
3. Approve the waiting run at the `production` environment, after the checks in [Before you approve](WORKFLOW.md#before-you-approve).

Each run builds the API with its commit, deploys it as a package, waits until `/health/live` reports that commit, then checks a few endpoints. Before a release, follow [Keeping released apps working](WORKFLOW.md#keeping-released-apps-working).

## Migrations

- **Dev:** apply them with `FitPlan.Migrator`, as in [Applying a migration to Dev](WORKFLOW.md#applying-a-migration-to-dev). The Dev deploy waits for your confirmation when migrations change.
- **Production:** there is no migration path yet. The Production deploy refuses any release that changes migrations. A path is planned in Phase 4.

Don't run migration scripts against Production by hand.

## Backups and recovery

See [RECOVERY.md](RECOVERY.md).
