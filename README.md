# تأسیسات‌یار (TasisatYar)

**آرشیو تخصصی و آفلاین عیب‌یابی و تعمیر تجهیزات تأسیسات ساختمانی** — نسخه ۱ (MVP) با تمرکز بر **پکیج** و **دستگاه‌های تصفیه آب**.

- ✅ کاملاً آفلاین — بدون نیاز به اینترنت، بدون API خارجی، بدون AI
- ✅ دیتابیس محلی **SQLite** با ایندکس جستجوی تمام‌متن **FTS5**
- ✅ رابط فارسی و **RTL واقعی** با فونت **وزیرمتن** (داخل بسته، آفلاین)
- ✅ جستجوی سریع در کد خطا، مشکل، قطعه، برند و مدل
- ✅ علاقه‌مندی‌ها و تاریخچه مشاهده — ذخیره محلی روی دستگاه
- ✅ تم روشن/تاریک — بدون دسترسی‌های غیرضروری

---

## ساخت خروجی (Build)

### پیش‌نیاز
1. نصب **Flutter SDK 3.24+**: https://docs.flutter.dev/get-started/install
2. نصب **Android Studio + Android SDK (API 34)** و **JDK 17**

### ساخت APK
```bash
cd tasisatyar
flutter pub get
flutter build apk --release      # خروجی: build/app/outputs/flutter-apk/app-release.apk
# یا برای انتشار در Google Play:
flutter build appbundle --release
```

> ساخت اول چند دقیقه طول می‌کشد (دانلود Gradle و وابستگی‌ها).

### ساخت خودکار با GitHub Actions
فایل `.github/workflows/android.yml` آماده است — کافی است پروژه را در یک ریپوی GitHub قرار دهید؛ APK خروجی در تب Actions قابل دانلود است.

### امضای رسمی (الزامی برای Google Play)
1. ساخت keystore:
```bash
keytool -genkey -v -keystore tasisatyar.keystore -alias tasisatyar -keyalg RSA -keysize 2048 -validity 10000
```
2. فایل `android/key.properties`:
```properties
storePassword=... 
keyPassword=...
keyAlias=tasisatyar
storeFile=../tasisatyar.keystore
```
3. در `android/app/build.gradle` بخش release را به keystore متصل کنید (نمونه در مستندات رسمی Flutter: *Sign the app*).

> ⚠️ keystore را هرگز داخل Git قرار ندهید.

---

## ساختار پروژه

```
tasisatyar/
├── assets/
│   ├── data/seed.json        # بانک اطلاعاتی MVP (خودکار تولید می‌شود)
│   ├── fonts/                # فونت وزیرمتن (آفلاین)
│   └── images/logo.png
├── lib/
│   ├── main.dart             # ورودی، تم و مسیرها
│   └── src/
│       ├── core/             # تم، رنگ‌ها، وضعیت سراسری
│       ├── data/             # مدل‌ها، دیتابیس SQLite، ریپازیتوری
│       └── ui/               # صفحات و ویجت‌ها (جدای از داده)
└── android/                  # پلتفرم اندروید (آماده ساخت)
```

### جداول دیتابیس (SQLite)
`brands` ، `devices` ، `error_codes` ، `problems` ، `components` ، `favorites` ، `history` ، `meta` و جدول مجازی `search_fts` برای جستجوی سریع.

## به‌روزرسانی بانک اطلاعاتی

1. فایل‌های JSON داخل پوشه `seed/` (در ریشه workspace) را ویرایش/تکمیل کنید؛ ساختار:
   - `brands_devices.json` — برندها و مدل‌ها
   - `errors_package.json` — کدهای خطا (علت‌ها، مراحل بررسی، راهکار، قطعات)
   - `problems_package.json` / `problems_purifier.json` — مشکلات علامت‌محور
   - `components.json` — قطعات و روش بررسی آن‌ها
2. اجرای مرج: `python3 tools/merge_seed.py` (مقادیر `db_version` در `meta` را افزایش دهید تا کاربران داده جدید را دریافت کنند).
3. Seed جدید با اولین اجرای نسخه جدید برنامه جایگزین داده قبلی می‌شود؛ علاقه‌مندی‌ها و تاریخچه کاربر حفظ می‌ماند.

> داده‌های فعلی با برچسب **«نمونه اولیه»** (در UI) مشخص شده‌اند تا داده معتبر و مدل‌محور در نسخه‌های بعدی جایگزین شود.

## حریم خصوصی
- همه اطلاعات (علاقه‌مندی‌ها، تاریخچه، تنظیمات) فقط روی دستگاه کاربر ذخیره می‌شود.
- برنامه هیچ داده‌ای ارسال نمی‌کند و سرویس آنلاینی ندارد.
- دسترسی INTERNET در مانیفست موردنیاز نیست.

## نقشه راه نسخه‌های بعدی
برندها/مدل‌ها/خطاهای بیشتر • تصاویر قطعات • PDF دفترچه‌ها • راهنمای تصویری • ورود تعمیرکار • ثبت مشتری و دستگاه • گزارش تعمیر • بانک اطلاعاتی آنلاین اختیاری
