# نشر الـ API على Azure

**الرابط:** https://fitplan-api-eyad.azurewebsites.net (الاشتراك: Azure for Students، المنطقة: UAE North)

## الموارد (كلها في `fitplan-rg`)
| المورد | الاسم | الخطة |
|---|---|---|
| App Service plan | `fitplan-plan` | F1 Linux (مجاني) |
| Web app | `fitplan-api-eyad` | .NET 10 |
| SQL server | `fitplan-sql-eyad` | المستخدم `fitplanadmin` |
| Database | `FitPlanDb` | Free offer (serverless، يوقف لحاله إذا خلص الحد المجاني) |

## الإعدادات (في Azure، مو في الكود)
- **Connection string:** `FitPlanDb`
- **App settings:**
  - `Jwt__Key`
  - `ASPNETCORE_ENVIRONMENT=Production`
  - `Uploads__Root=/home/data/uploads`: صور البروفايل تنحفظ هنا عشان ما تنمسح مع كل نشر.

كلمة سر SQL والـ JWT key محفوظة **بس** في إعدادات Azure، وعلى جهازك برا الـ repo. لا تحطها في git.

## نشر نسخة جديدة
```
cd Backend/FitPlan.Api
dotnet publish -c Release -o publish
az webapp deploy -g fitplan-rg -n fitplan-api-eyad --type zip --clean true --src-path api.zip
```
- **مسارات الـ zip:** لازم تكون بـ `/`. أداة `Compress-Archive` حق Windows تكتبها بـ `\`، وسيرفر Linux يرفض الملف.
- **مجلد `wwwroot/uploads`:** لا ترفعه، لأن فيه صور محلية.

## Migrations جديدة
```
dotnet ef migrations script --idempotent -o migrate.sql
sqlcmd -S tcp:fitplan-sql-eyad.database.windows.net,1433 -d FitPlanDb -U fitplanadmin -N -I -b -i migrate.sql
```
الخيار `-I` ضروري، لأن بعض الـ indexes تحتاج `QUOTED_IDENTIFIER ON`.

**قبل ما تشغّل الأوامر:** الـ firewall في `fitplan-sql-eyad` يسمح بس لخدمات Azure وللـ IP اللي سوينا منه الإعداد. إذا تغيّر الـ IP حقك، ضيف قاعدة جديدة له.
