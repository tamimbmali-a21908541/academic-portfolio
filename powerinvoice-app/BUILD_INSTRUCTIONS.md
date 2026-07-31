# PowerInvoice - Building Release APK

## Why Windows Flags the APK as a Virus

This is a **FALSE POSITIVE**. Windows Defender often flags Android APKs as viruses because:
- They're self-signed (not from Google Play Store)
- They request permissions (contacts, storage, etc.)
- APK format can trigger heuristic detection

Your app is safe! It's just Windows being overly cautious.

## Quick Fix: Add Windows Defender Exclusion

1. Open **Windows Security** → **Virus & threat protection**
2. Click **Manage settings** → Scroll to **Exclusions**
3. Click **Add or remove exclusions** → **Add an exclusion** → **Folder**
4. Select: `PowerInvoice/mobile-app/powerinvoice_app/build/app/outputs/flutter-apk/`

---

## Build a Properly Signed Release APK

### Step 1: Generate Signing Key (One-Time Setup)

Run this command in the `android` folder:

```bash
cd /workspaces/PowerInvoice/mobile-app/powerinvoice_app/android
bash create_keystore.sh
```

You'll be asked for:
- **Keystore password**: Choose a strong password (remember it!)
- **Key password**: Can be same as keystore password
- **Name and organization**: Your company/personal info

This creates: `powerinvoice-key.jks`

**IMPORTANT**: Keep this file and passwords SAFE! You need them to update the app later.

### Step 2: Create key.properties File

```bash
cd /workspaces/PowerInvoice/mobile-app/powerinvoice_app/android
cp key.properties.example key.properties
nano key.properties  # or use any text editor
```

Fill in YOUR passwords:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=powerinvoice
storeFile=powerinvoice-key.jks
```

### Step 3: Build the Release APK

```bash
cd /workspaces/PowerInvoice/mobile-app/powerinvoice_app
flutter build apk --release
```

### Step 4: Find Your APK

The signed APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Alternative: Build Without Signing (Debug Mode)

If you don't need a properly signed APK and just want to test:

```bash
flutter build apk --debug
```

Then add Windows Defender exclusion (see top of this file).

---

## Install APK on Android Device

### Method 1: USB Cable
1. Connect phone to computer
2. Enable **Developer Options** and **USB Debugging** on phone
3. Run: `flutter install`

### Method 2: Share APK File
1. Copy `app-release.apk` to your phone (via USB, email, cloud, etc.)
2. Open the APK file on your phone
3. Allow "Install from unknown sources" if prompted
4. Install the app

---

## Troubleshooting

### "Virus detected" on Windows
- Add exclusion to Windows Defender (see top)
- Or use properly signed release APK (steps above)

### "App not installed" on Android
- Uninstall old version first
- Enable "Install from unknown sources"
- Make sure APK isn't corrupted

### Build fails with signing error
- Check that `key.properties` exists
- Verify passwords are correct
- Make sure `powerinvoice-key.jks` is in the android folder

---

## Security Notes

- **NEVER commit** `key.properties` or `*.jks` files to git
- **Backup** your keystore file - you can't regenerate it
- **Remember** your passwords - there's no password recovery
- Use the **same keystore** for all future updates to the app

---

## Google Drive Feature Setup

After installing, when you use "Save to Google Drive":
1. You'll be prompted to sign in
2. Authorize PowerInvoice to access Drive
3. PDFs will be saved to your Drive root folder

You can revoke access anytime via Google Account Settings → Security → Third-party apps.
