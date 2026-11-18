# Backup and recovery

How to get data back, move it, and rebuild Dev. Rolling back a bad API release is in [WORKFLOW.md](WORKFLOW.md#if-a-production-deploy-fails).

Any action on Production in this file needs Eyad's approval first, step by step.

## What is backed up

| What | Backup | Kept for |
| --- | --- | --- |
| Database (`FitPlanDb`, `FitPlanDb-dev`) | Azure's automatic backups, locally redundant | 7 days, point in time |
| Database, long term | None in Azure. A manual export (below) is the only long-term copy. | As long as you keep the file |
| Profile pictures (`/home/data/uploads`) | **None.** Database backups don't include them. | Not covered yet (F-06) |

Both databases use the free offer. **A database restored from a backup is never free.** Microsoft doesn't allow the free offer on a restored or copied database, so every restore creates a paid database. Restore to Basic, the cheapest tier, unless the data is larger than 2 GB.

## Tested results

| Test | Date | Result |
| --- | --- | --- |
| Point-in-time restore of `FitPlanDb-dev` to Basic | 2026-11-16 | 28 minutes 5 seconds for 22 MB. The new database was Basic, not free. Schema fingerprint and row counts of every table matched Dev. Deleted after about 12 minutes. |
| Export of `FitPlanDb-dev` to a `.bacpac` | 2026-11-16 | 79 seconds, 6 KB file. Dev holds one user and no exercises, so this proves the steps, not the time for real data. |
| Import of that file into local SQL Server Express | 2026-11-16 | 58 seconds. Schema fingerprint and row counts of every table matched Dev. |

## Restore a database to a point in time

Use this when data was damaged or deleted in the last 7 days. The restore creates a new database next to the original. It never overwrites it.

1. Pick a UTC time just before the damage. It must be after the earliest restore point:

   ```bash
   az sql db show -g fitplan-dev-rg -s fitplan-sql-eyad-dev -n FitPlanDb-dev --query earliestRestoreDate -o tsv
   ```

2. Restore to Basic, at about $0.21 a day while it exists:

   ```bash
   az sql db restore -g fitplan-dev-rg -s fitplan-sql-eyad-dev -n FitPlanDb-dev \
     --dest-name FitPlanDb-dev-restoretest --time 2026-11-16T06:39:50Z \
     --edition Basic --service-objective Basic --backup-storage-redundancy Local
   ```

   The command can run for half an hour, even for a small database. The new database doesn't appear in the list until the restore finishes. If the terminal gives up, the restore keeps going. Check with `az sql db list`.

3. Check the restored data before using it, for example row counts per table.
4. Decide how to use it:
   - **Copy back only what was lost**, from the restored database into the original. Nothing else changes.
   - **Move everything back to a free database:** export the restored database and import it into a new free database (below), then point the app at it.
5. Delete the restored database as soon as you no longer need it, so billing stops:

   ```bash
   az sql db delete -g fitplan-dev-rg -s fitplan-sql-eyad-dev -n FitPlanDb-dev-restoretest --yes
   ```

For Production, the names are `fitplan-rg`, `fitplan-sql-eyad` and `FitPlanDb`. Production's restore hasn't been tested. Pointing the Production app at another database changes its connection string, which needs approval.

## Export a database to a file

An export is a `.bacpac` file with the schema and all the data. Keep it outside the repository, because it holds user data. Never commit it.

1. Install SqlPackage once:

   ```bash
   dotnet tool install -g microsoft.sqlpackage
   ```

2. Add a temporary firewall rule for your IP, as in [WORKFLOW.md](WORKFLOW.md#temporary-sql-firewall-rules).
3. Export. Dev signs in with your Microsoft Entra account:

   ```bash
   sqlpackage /Action:Export \
     /SourceConnectionString:"Server=tcp:fitplan-sql-eyad-dev.database.windows.net,1433;Database=FitPlanDb-dev;Authentication=Active Directory Default;Encrypt=True" \
     /TargetFile:"<backup-folder>\FitPlanDb-dev-YYYY-MM-DD.bacpac"
   ```

   Use a private folder outside the repository for `<backup-folder>`.

   In Git Bash, put `MSYS_NO_PATHCONV=1` before `sqlpackage`, or it rewrites the `/` arguments into paths.

4. Delete the firewall rule.

An export reads from the live database, so a write during the export can leave the file inconsistent. For a consistent copy, export from a restored database instead.

## Import a file into a new database

The target database must be new or empty.

- **Local SQL Server:**

  ```bash
  sqlpackage /Action:Import /SourceFile:"<backup-folder>\FitPlanDb-dev-YYYY-MM-DD.bacpac" \
    /TargetConnectionString:"Server=localhost\SQLEXPRESS;Database=FitPlanRestore_Dev;Trusted_Connection=True;TrustServerCertificate=True"
  ```

- **A new free Azure database:** create it with the free offer first, then import into it with the same command and an Azure connection string:

  ```bash
  az sql db create -g fitplan-dev-rg -s fitplan-sql-eyad-dev -n FitPlanDb-dev-new \
    --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 2 \
    --use-free-limit --free-limit-exhaustion-behavior AutoPause
  ```

  A subscription can hold up to 10 free databases. This path hasn't been tested yet.

## Rebuild Dev from scratch

Use this if the subscription is closed or the Dev resources are lost. You need the latest export file and access to the GitHub repository.

| Order | Resource | Name and settings |
| --- | --- | --- |
| 1 | Resource group | `fitplan-dev-rg`, UAE North |
| 2 | SQL server | `fitplan-sql-eyad-dev`, Microsoft Entra authentication only, your account as admin |
| 3 | Database | `FitPlanDb-dev`, free offer, auto-pause when the free limit is used up. Import the export file into it. |
| 4 | App Service plan | `fitplan-plan-dev`, F1 Linux |
| 5 | Web app | `fitplan-api-dev`, .NET 10, HTTPS only, system-assigned managed identity |
| 6 | App settings | `ASPNETCORE_ENVIRONMENT`, `Uploads__Root=/home/data/uploads`, `Exercises__CacheFile=/home/data/cache/exercises.json`, a new `Jwt__Key`, and connection string `FitPlanDb` (type `SQLAzure`) using `Authentication=Active Directory Managed Identity` |
| 7 | Database user for the app | A contained user for the web app's identity, with read and write roles |
| 8 | Firewall | One `dev-app-out-*` rule per outbound IP of the web app |
| 9 | Migration user | `fitplan-migrator`, a user without a login, with `db_ddladmin`, `db_datareader` and `db_datawriter`. Never `db_owner`. |
| 10 | Deploy identity | `fitplan-gh-dev`, with a federated credential for `repo:Eng-Eyad77@177796235/FitPlan@1408724659:environment:dev`, and the custom role **FitPlan Web Deploy** on `fitplan-api-dev` only |
| 11 | GitHub environment secrets | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` in `dev`. If the subscription or identity changed, update them. |
| 12 | Alerts | Free-tier usage at 50% and 80%, and every Dev SQL firewall change, emailing `fitplan-free-tier-alerts` |

The **FitPlan Web Deploy** role allows only `Microsoft.Web/sites/read`, `Microsoft.Web/sites/publish/Action` and `Microsoft.Web/sites/basicPublishingCredentialsPolicies/read`. It can't read app settings or connection strings.

After the rebuild, re-run the last successful Deploy Dev run. It must pass its checks, and `/api/exercises` must return 200.

A new `Jwt__Key` signs out every user, which is expected. Profile pictures aren't in the export, so they're lost unless copied separately.
