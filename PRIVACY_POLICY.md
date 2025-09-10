# Privacy Policy

**Last Updated:** September 2025

## Introduction

This privacy policy explains how the cloth app ("we", "our", or "us") handles your information when you use our mobile application. We are committed to protecting your privacy and being transparent about our data practices.

## About This App

cloth is an open-source tool for sustainable fashion that helps you organize and track your clothing items and outfits. The app is designed with privacy in mind and stores all your data locally on your device.

## Data We Store

### Personally Identifiable Information
The cloth app does **not** collect or store any personally identifiable information. We do not require you to create an account or provide personal details like your name, email address, or phone number.

### Data Stored Locally
The app stores the following information locally on your device:

**Clothing Items:**
- Item name, category, and subcategory
- Brand, color, and materials
- Purchase price and date
- Season and origin information
- Laundry impact and repairability notes
- Personal notes you add
- Photos you take of items
- Wear count and usage tracking
- Creation and modification timestamps

**Outfits:**
- Date when the outfit was worn
- List of clothing items in the outfit
- Personal notes about the outfit
- Photos of the complete outfit
- Creation and modification timestamps

**App Settings:**
- Your preferences for data export/import
- Analytics settings (if enabled)
- Other app configuration options

### Data Storage Location
- **Android:** `/data/data/[package_name]/app_flutter/`
- **iOS:** `~/Documents/`
- **Windows/macOS/Linux:** App's data directory

All data is stored using Hive, a local NoSQL database, and remains on your device at all times.

## Data Transmission

**We do not transmit any of your data to external servers.** The app operates entirely offline and does not send your clothing information, photos, or any other data to our servers or third parties.

The only network activity occurs when:
- You choose to export your data (files are saved locally)
- You use the URL launcher to open external links (like support pages)
- You share files using your device's native sharing functionality

## How We Use Your Data

Since all data remains on your device, we do not have access to or use your personal information. The app uses your data only to:

- Display your clothing items and outfits in the app interface
- Calculate statistics like cost per wear
- Enable data export and import functionality
- Provide search and filtering capabilities
- Track usage patterns for app improvement (only if analytics are enabled)

## App Permissions

The cloth app requests the following permissions:

### Camera Permission
- **Purpose:** To take photos of your clothing items and outfits
- **When requested:** Only when you choose to add a photo
- **Required:** No - you can use the app without taking photos

### Photo Library Access
- **Purpose:** To select existing photos from your device's photo library
- **When requested:** Only when you choose to add a photo from your library
- **Required:** No - you can use the app without adding photos

### File System Access
- **Purpose:** To save exported data files and access imported files
- **When requested:** Only when you use export/import features
- **Required:** No - you can use the app without exporting/importing data

### Internet Access (Development Only)
- **Purpose:** Required for Flutter development tools (hot reload, debugging)
- **When requested:** Only during development builds
- **Required:** No - production builds do not require internet access

## Data Deletion

You have full control over your data:

### Delete Individual Items
- You can delete individual clothing items or outfits at any time
- Items are marked as inactive rather than permanently deleted (soft deletion)
- This allows for data recovery if needed

### Delete All Data
- The app includes a "Delete all data" option in the settings
- This permanently removes all your clothing items, outfits, and photos
- This action cannot be undone

### Uninstall the App
- Uninstalling the app will remove all associated data from your device
- Make sure to export your data before uninstalling if you want to keep it

## Analytics and Usage Data

The app includes an optional analytics feature that you can enable or disable in the settings:

- **What it tracks:** Anonymous usage statistics to help improve the app
- **What it doesn't track:** Your personal data, clothing information, or photos
- **Default setting:** Disabled
- **Data transmission:** Analytics data (if enabled) may be sent to help improve the app

## Data Export and Import

The app allows you to export and import your data:

### Export Formats
- **JSON:** Complete data backup with all information and photos
- **CSV:** Spreadsheet-compatible format (without photos)

### Data Portability
- You can export your data at any time
- Exported files are saved locally on your device
- You can share these files using your device's native sharing functionality

## Third-Party Services

The cloth app does not integrate with any third-party services that would have access to your data. The app uses only:

- **Hive Database:** For local data storage
- **Flutter Framework:** For app functionality
- **Device APIs:** For camera, file system, and sharing functionality

## Children's Privacy

The cloth app does not collect personal information from anyone, including children under 13. The app is safe for users of all ages.

## Security

We take data security seriously:

- All data is stored locally on your device
- No data is transmitted over the internet
- The app uses secure local storage mechanisms
- Your data is protected by your device's security features

## Changes to This Privacy Policy

We may update this privacy policy from time to time. When we do, we will:

- Update the "Last Updated" date at the top of this policy
- Notify you through the app if significant changes are made
- Post the updated policy in the app's settings

## Contact Information

If you have any questions about this privacy policy or need help with data deletion, please contact us:

- **Email:** [Your contact email]
- **GitHub:** [Your GitHub repository URL]
- **Support:** Through the app's settings menu

## Your Rights

You have the right to:
- Access all data stored by the app (it's all on your device)
- Delete your data at any time
- Export your data in standard formats
- Disable analytics tracking
- Use the app without providing any personal information

## Open Source

The cloth app is open source, which means:
- The source code is publicly available for review
- You can verify our privacy claims by examining the code
- The community can help identify and fix any privacy issues
- You can contribute to improving the app's privacy features

---

*This privacy policy is written in simple, clear language to help you understand how your data is handled. If you have any questions or concerns, please don't hesitate to contact us.*
