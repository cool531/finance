# Releasing Luxury Finance to Google Play

Everything in the repo is ready except the signing key, which only you can
create — it is the one secret that must never be committed or shared.

---

## 1. Create your upload keystore (once, ever)

Losing this file means you can never update the app under the same listing
again, so back it up somewhere durable (password manager, encrypted drive).

Run this yourself and pick your own passwords when prompted:

```bash
keytool -genkey -v -keystore "$HOME/keys/luxury-finance-upload.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`keytool` ships with the JDK bundled in Android Studio:
`C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`

## 2. Point the build at it

Copy `android/key.properties.example` to `android/key.properties` and fill in
the four values. That file is git-ignored, along with `*.jks` and `*.keystore`.

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/Users/<you>/keys/luxury-finance-upload.jks
```

Without `key.properties` the release build still succeeds, but it is signed
with the **debug** key and Play will reject it. The Gradle config says which
one it used.

## 3. Build the bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab` — this is the file
you upload. (`flutter build apk` is only for sideloading; Play wants the .aab.)

Check which key signed it before uploading:

```bash
jarsigner -verify -verbose:summary build/app/outputs/bundle/release/app-release.aab
```

## 4. Play Console setup

| Field | Value |
| --- | --- |
| App name | Luxury Finance |
| Package name | `com.cool531.luxuryfinance` |
| Default language | ไทย (th-TH) |
| Category | Finance |
| Content rating | Everyone — see `listing.md` for the questionnaire answers |
| Ads | No |
| In-app purchases | No |

Assets to upload, all in this folder:

- `play_store_icon_512.png` — 512×512 app icon
- `feature_graphic_1024x500.png` — the banner at the top of the listing
- `screenshots/` — phone screenshots (Play requires at least 2)
- Listing text — copy from `listing.md`
- Privacy policy — host `PRIVACY.md` at a public URL and paste that URL

## 5. Data safety form

The app has no network code at all and declares no permissions, so:

- **Does your app collect or share user data?** → No
- **Is all user data encrypted in transit?** → N/A (no data leaves the device)
- **Do you provide a way to delete data?** → Yes, Settings → ลบข้อมูลทั้งหมด

## 6. Shipping an update

1. Bump `version:` in `pubspec.yaml` — e.g. `1.0.1+2`. The build number (after
   the `+`) must increase on every upload or Play rejects the bundle.
2. Update `appVersion` / `appBuildNumber` in `lib/app_info.dart` to match;
   that is what the Settings screen shows.
3. `flutter test && flutter build appbundle --release`
4. Upload, write release notes, roll out.

---

## Pre-upload checklist

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] `key.properties` present, bundle signed with the upload key
- [ ] Installed the release build on a real phone and added one expense
- [ ] Version bumped in both `pubspec.yaml` and `lib/app_info.dart`
- [ ] Privacy policy URL reachable
- [ ] Decided on the final package name — **it can never change after the
      first upload**. It is currently `com.cool531.luxuryfinance`, set in
      `android/app/build.gradle.kts` (`namespace` + `applicationId`) and in the
      folder name under `android/app/src/main/kotlin/`.
