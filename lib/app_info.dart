/// App identity shown in the UI and the store listing.
///
/// Keep [appVersion] and [appBuildNumber] in step with `version:` in
/// pubspec.yaml — that line is what Gradle turns into versionName/versionCode.
library;

const String appName = 'Luxury Finance';
const String appVersion = '1.0.0';
const String appBuildNumber = '1';
const String appVersionLabel = '$appVersion ($appBuildNumber)';
