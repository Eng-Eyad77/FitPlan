# Deploying the API to Azure

**URL:** https://fitplan-api-eyad.azurewebsites.net (subscription: Azure for Students, region: UAE North)

## Resources (all in `fitplan-rg`)
| Resource | Name | Plan |
|---|---|---|
| App Service plan | `fitplan-plan` | F1 Linux (free) |
| Web app | `fitplan-api-eyad` | .NET 10 |
| SQL server | `fitplan-sql-eyad` | admin user `fitplanadmin` |
| Database | `FitPlanDb` | Free offer (serverless; pauses by itself when the monthly free limit is used up) |

## Settings (in Azure, not in the code)
- **Connection string:** `FitPlanDb`
- **App settings:**
  - `Jwt__Key`
  - `ASPNETCORE_ENVIRONMENT=Production`
  - `Uploads__Root=/home/data/uploads`: profile pictures are saved here so they survive deploys.

The SQL password and the JWT key live **only** in the Azure settings and in a local file outside the repository. Never commit them.

## Deploying a new version
```
cd Backend/FitPlan.Api
dotnet publish -c Release -o publish
az webapp deploy -g fitplan-rg -n fitplan-api-eyad --type zip --clean true --src-path api.zip
```
- **Zip paths:** entries must use `/`. Windows' `Compress-Archive` writes `\`, and the Linux server rejects the package.
- **`wwwroot/uploads`:** leave it out of the zip; it holds local pictures.

## New migrations
```
dotnet ef migrations script --idempotent -o migrate.sql
sqlcmd -S tcp:fitplan-sql-eyad.database.windows.net,1433 -d FitPlanDb -U fitplanadmin -N -I -b -i migrate.sql
```
The `-I` flag is required, because some indexes need `QUOTED_IDENTIFIER ON`.

**Before running these:** the firewall on `fitplan-sql-eyad` only allows Azure services and the IP the setup was done from. If your IP changes, add a rule for the new one.
