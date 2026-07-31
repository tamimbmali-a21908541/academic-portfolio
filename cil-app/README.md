# CIL — Comunidade Islâmica de Lisboa

**Official mobile app for the Islamic Community of Lisbon**, built with Flutter for Android and iOS.

A community platform for the Lisbon Central Mosque: prayer times computed for the user's actual location, the Islamic calendar, community news and events, membership, donations, and mosque services — in three languages.

## Features

| Feature | Detail |
|---|---|
| 🕌 **Prayer times** | Calculated locally with the [adhan](https://pub.dev/packages/adhan) astronomical library, adjusted to the device's GPS position and timezone — no server round-trip needed |
| 🔔 **Prayer notifications** | Local notifications via `flutter_local_notifications` |
| 📅 **Hijri calendar** | Islamic dates alongside the Gregorian calendar |
| 📰 **News & events** | Community announcements and event listings |
| 💳 **Membership & donations** | Member area and donation flows |
| 💍 **Mosque services** | Wedding services and contact |
| 🗺️ **Map** | Mosque location with `flutter_map` |
| 🌍 **Localised** | Portuguese, English, and French (`lib/l10n`) |

## Architecture

Feature-first structure — each domain owns its screens, providers, and widgets:

```
lib/
├── core/          # constants, providers, services, theme, utils
├── features/      # auth, prayer_times, calendar, events, news,
│                  # donation, membership, wedding, profile, ...
├── l10n/          # EN / FR / PT localisation
└── main.dart
```

- **State management:** Provider
- **Routing:** go_router
- **Networking:** dio + http
- **Offline storage:** Hive + shared_preferences

## Getting started

```bash
flutter pub get
flutter run
```
