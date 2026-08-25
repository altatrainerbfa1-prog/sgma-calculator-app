# Singapore Mortgage Advisory — Calculator App (Build via GitHub, No Install Needed)

This repo is set up so **GitHub's own servers** compile the Android app —
no Flutter or Android Studio install needed on your end.

## How it works

The `.github/workflows/build.yml` file tells GitHub Actions to automatically
download Flutter, build the app, and produce an installable `.apk` file
every time code is pushed to `main`.

## Get the built APK

1. Click the **Actions** tab above.
2. Click the most recent run (green checkmark = success).
3. Scroll to the bottom to **Artifacts**, download `sgma-calculators-apk`.
4. Unzip it, get `app-release.apk`, transfer to an Android phone, and tap to
   install (allow "install from this source" when prompted, that's normal
   for an app not yet on the Play Store).

## What's inside

- `lib/` — full app source, all 6 calculators, logic matches the live
  website's calculators.
- `pubspec.yaml` — project manifest.
- `.github/workflows/build.yml` — the build robot.

## Not done yet

This produces a real installable Android app for testing on your own phone.
Still needed before a Play Store listing: a Google Play Console account
(one-time US$25), a proper app icon/branding, a signed release bundle, and
the store listing itself (description, screenshots, privacy policy).
