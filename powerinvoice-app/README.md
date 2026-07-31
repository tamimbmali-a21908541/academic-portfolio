# PowerInvoice

**A standalone Flutter invoicing app — clients, products, invoices, and payments managed entirely on the phone.**

No server, no account, no subscription: data lives on-device, invoices are generated as PDFs locally, and backups go to the user's own Google Drive.

## Features

| Feature | Detail |
|---|---|
| 🧾 **PDF invoices on-device** | Invoices are composed and rendered locally with the `pdf` package, then previewed, printed, or shared (`printing`, `share_plus`) — no server round-trip |
| 💼 **Clients, products, payments** | Full CRUD with dedicated forms; partial and full payment tracking per invoice |
| 📇 **Contact import** | Pull client details straight from the phone's contacts (`flutter_contacts`) |
| ☁️ **Google Drive backup** | Backup and restore to the user's own Drive via Google Sign-In and the Drive v3 API |
| 🔐 **Offline activation** | Device-bound licence-key system — the app can be distributed and activated with no backend at all |
| 🔢 **Invoice numbering** | Sequential invoice numbers that survive app restarts |
| 🗄️ **Archive** | Completed invoices move out of the working list without being deleted |

## Architecture

```
lib/
├── models/      # client, product, invoice, payment
├── forms/       # one form per model
├── screens/     # dashboard, clients, products, invoices, archive, activation
├── services/    # storage, Google Drive backup, invoice counter, activation
└── main.dart
```

- **Storage:** JSON-serialised models in `shared_preferences` — offline-first by design
- **PDF:** `pdf` + `printing`
- **Cloud backup:** `google_sign_in` + `googleapis` (Drive v3)

## Getting started

```bash
flutter pub get
flutter run
```

To build a release APK, see [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md).
