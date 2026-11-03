# تجربة FitPlan على جوال حقيقي (مجاناً)

## 1. شغّل الـ API على الشبكة (كل مرة تجرب)
الجوال والكمبيوتر لازم يكونون على **نفس الـ Wi-Fi**.

1. من مجلد المشروع:
   ```
   dotnet run --project Backend/FitPlan.Api --launch-profile lan
   ```
2. أول مرة بيطلع لك Windows Firewall يسأل: اختر **Private networks** واضغط **Allow**. لا تختار Public.
3. اعرف IP جهازك: `ipconfig` ← سطر **IPv4 Address** حق الـ Wi-Fi (حالياً `192.168.1.13`).
4. تأكد من الجوال: افتح Safari على `http://192.168.1.13:5264/api/exercises?pageSize=1`. إذا طلع لك نص JSON، الاتصال تمام.

> إذا تغيّر الـ IP (الراوتر يغيّره أحياناً) لازم تعيد البناء بالـ IP الجديد. الحل الدائم: من إعدادات الراوتر احجز IP ثابت لجهازك (DHCP reservation).

## 2. iPhone: بناء التطبيق على Codemagic
1. سجّل في [codemagic.io](https://codemagic.io) بحساب GitHub، واختر الـ repo `FitPlan`.
2. Codemagic بيقرأ ملف `codemagic.yaml` تلقائياً. اختر workflow **iPhone test build (unsigned)**.
3. إذا الـ IP غير `192.168.1.13`، عدّل `API_BASE_URL` في الملف أو في Environment variables.
4. اضغط **Start build** (حوالي 10 دقائق). بعد ما يخلص حمّل **FitPlan-test.ipa** من Artifacts.

## 3. iPhone: التثبيت بـ Sideloadly (على Windows)
1. ثبّت **iTunes** من موقع Apple (مو من Microsoft Store) و **Sideloadly** من موقعه الرسمي `sideloadly.io`.
2. وصّل الآيفون بالكيبل، واضغط **Trust** على الجوال.
3. اسحب ملف الـ `.ipa` على Sideloadly، واكتب Apple ID، واضغط **Start**.
   - يُفضّل تستخدم **Apple ID ثانوي** للتجربة، مو حسابك الأساسي.
4. على الآيفون:
   - **Settings ← Privacy & Security ← Developer Mode** شغّله، وبيعيد تشغيل الجوال (iOS 16 وأحدث).
   - **Settings ← General ← VPN & Device Management** ← اختر الـ Apple ID ← **Trust**.
5. افتح FitPlan. أول مرة بيسألك عن **Local Network**، اضغط **Allow**، بدونها ما يوصل للسيرفر.

**القيود:** التطبيق يشتغل **7 أيام** وبعدها تعيد الخطوة 3 (دقيقة وحدة)، ولين 3 تطبيقات بنفس الطريقة.

## 4. Android: ملف APK لأي جوال Android
```
cd Frontend/fitplan_app
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.13:5264
```
الملف: `Frontend/fitplan_app/build/app/outputs/flutter-apk/app-release.apk`. أرسله، وعند التثبيت الجوال بيطلب السماح بالتثبيت من مصدر غير المتجر.

## 5. قائمة التجربة على الجوال
- [ ] تسجيل حساب جديد، تسجيل خروج، تسجيل دخول، وكلمة سر غلط
- [ ] صورة البروفايل من **الكاميرا** ومن **الصور** (رسائل الأذونات تطلع)
- [ ] إضافة وزن الجسم، والـ weekly goal
- [ ] خطة جديدة: إضافة تمارين، تعديل الـ target، ترتيب بالسحب، حذف تمرين
- [ ] البحث في التمارين، والـ GIFs تشتغل، وتفاصيل التمرين
- [ ] تمرين كامل: sets، تعديل set، حذف set، rest timer (+15s و Skip)، cardio، finish
- [ ] **اقفل التطبيق نهائياً وسط تمرين وافتحه**: لازم يرجع للتمرين
- [ ] تمرين ثاني بنفس الخطة: الاقتراح 💡 والـ PRs والمقارنة
- [ ] History: التفاصيل والحذف
- [ ] Progress: الشارتات، والضغط عليها يطلع القيم
- [ ] الكيبورد ما يغطي الحقول، وما فيه نص مقصوص
- [ ] **الآيفون فقط:** الـ notch والـ home indicator ما يغطون أزرار، والـ swipe back يشتغل

اكتب أي مشكلة مع صورة شاشة وأنا أصلحها.
