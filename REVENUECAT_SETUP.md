# RevenueCat & In-App Purchase Setup Guide

This guide explains how to configure your coin products in Apple App Store and Google Play Store, and how to link them to the Sorto project in RevenueCat.

## 1. App Store Connect (iOS) Setup

### Create Products
1. Go to [App Store Connect](https://appstoreconnect.apple.com/) > My Apps > **Sorto**.
2. Navigate to **In-App Purchases** > **Manage**.
3. Click the **+** button to add a new product.
4. Select **Consumable** (since coins are used up).
5. Use the following identifiers (must match `lib/core/constants/coin_tiers.dart`):
   - `coins_100`
   - `coins_300`
   - `coins_500`
   - `coins_1000`
   - `coins_2000`
   - `coins_5000`
6. Set the price (e.g., ₹99, ₹299, etc.).
7. **Important**: Fill in the "Review Information" (screenshot and notes) or the products won't be approved.

### Link to RevenueCat
1. Go to **Users and Access** > **Integrations** > **In-App Purchase**.
2. Generate an **In-App Purchase Key** (.p8 file).
3. Copy your **Issuer ID** and **Key ID**.
4. In [RevenueCat Dashboard](https://app.revenuecat.com/):
   - Project Settings > Apps > **Add iOS App**.
   - Enter your Bundle ID.
   - Upload the `.p8` file and enter the Issuer/Key IDs.

---

## 2. Google Play Console (Android) Setup

### Create Products
1. Go to [Google Play Console](https://play.google.com/console/) > Select your app.
2. Navigate to **Monetize** > **Products** > **In-app products**.
3. Click **Create product**.
4. Use the same identifiers as iOS (e.g., `coins_100`).
5. Ensure the product is marked as **Active**.

### Link to RevenueCat
1. Go to **Setup** > **API access**.
2. Link a **Google Cloud Project**.
3. Create a **Service Account** with "Monitoring Viewer", "Pub/Sub Admin", and "Google Play Billing" permissions.
4. Download the **JSON Key file**.
5. In [RevenueCat Dashboard](https://app.revenuecat.com/):
   - Project Settings > Apps > **Add Android App**.
   - Enter your Package Name.
   - Upload the Service Account JSON key.

---

## 3. Connecting Everything in RevenueCat

Since I have already configured the **Entitlements**, **Offerings**, and **Packages** for you, you only need to:

1. **Add the Stores**: Add your iOS and Android apps to the project as described above.
2. **Import Products**:
   - Go to **Project Settings** > **Products**.
   - Click **+ Add Product**.
   - Select the App (iOS or Android).
   - Enter the Store Identifier (e.g., `coins_100`).
3. **Attach to Packages**:
   - Go to **Offerings** > **Default Offering**.
   - Click on a package (e.g., `coins_100`).
   - Click **Attach Product** and select the store-specific product you just added.

### Why this is needed?
RevenueCat acts as a "bridge". Your Flutter code asks for the `default_offering`. RevenueCat looks at the user's device (iOS or Android) and returns the correct store product and local price that you linked to that package.

---

## Troubleshooting
- **Empty Offerings**: Usually means the Bundle ID in RevenueCat doesn't match the app, or the products in the store are not "Cleared for Sale".
- **Invalid Credentials**: Double-check that your `.p8` (Apple) or JSON key (Google) has the correct permissions.
