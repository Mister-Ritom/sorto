# Privacy Policy

**«App Name»** is built with privacy as a core principle. We believe you should always know exactly what data we collect, why we collect it, and what we do — and *don't* do — with it. This policy is written in plain English because you deserve clarity, not legalese.

---

## 1. Who We Are

«App Name» ("the App") is developed and operated by **«Company Name»**.

- **Contact Email:** «Contact Email»
- **Website:** https://sorto.ritom.in

Throughout this policy, "we," "us," and "our" refer to «Company Name», and "you" and "your" refer to you, the user.

---

## 2. Our Privacy Philosophy

We built «App Name» on a simple principle: **collect only what we need, protect everything we have, and never exploit your data for profit.**

- We do **not** sell your personal data to anyone — ever.
- We do **not** build advertising profiles about you.
- We do **not** serve third-party ads.
- We do **not** use analytics or tracking SDKs that monitor your behavior.
- We do **not** access your contacts, location, or any data beyond what is explicitly listed below.

---

## 3. Information We Collect

### 3.1 Account Information (Provided by You)

When you create an account, we collect:

| Data | Purpose | Required? |
|------|---------|-----------|
| **Email address** | Account authentication, password recovery, and critical account notifications | Yes |
| **Password** | Securing your account (stored as a salted hash — we never see or store your plaintext password) | Yes (email sign-up) |
| **Username** | Your unique public identity within the app | Yes |
| **Display name** | Shown on your public profile and alongside your dares/posts | Optional |

If you sign in with **Google OAuth**, we receive your Google account email, name, and profile photo URL. We do not receive or store your Google password, and Google does not give us access to your contacts, calendar, Drive files, or any other Google service data.

### 3.2 Profile Information (Provided by You)

You may optionally provide:

- **Profile photo** — Uploaded to our storage and displayed publicly on your profile.
- **Bio text** — A short description displayed on your public profile.

### 3.3 User-Generated Content

When you use the App, you create content that we store:

- **Dares** — Title, description, category, tags, bounty amount, and dare mode.
- **Performer posts** — Title, description, category, and asking price.
- **Proof submissions** — Video files and optional text submitted as dare proof.

All user-generated content is stored on our servers and may be visible to other users as part of the App's core functionality.

### 3.4 Financial & Transaction Data

| Data | Purpose |
|------|---------|
| **Wallet balances** (coin balance, escrow balance, earned balance) | Displaying your in-app currency status |
| **Transaction history** | Recording coin purchases, dare payouts, platform fees, and withdrawals |
| **UPI ID** (for withdrawals) | Processing payouts to your bank account — sent to our server-side function only when you initiate a withdrawal |

**What we do NOT collect or store:**

- We never see, process, or store your credit/debit card numbers, bank account details, or full payment credentials.
- On **Android and iOS**, in-app purchases are handled entirely by **RevenueCat** via the Apple App Store or Google Play Store. Your payment card details are processed by Apple/Google — we only receive a purchase confirmation and the number of coins to credit.
- On **Web**, payments are processed by **Razorpay**. Your card or payment method details are entered directly into Razorpay's secure checkout widget. We receive only an order ID, payment ID, and cryptographic signature for verification — never your card number.

### 3.5 Device & Technical Data

We collect minimal technical data necessary for the App to function:

- **Device locale/country code** — Derived from your device's system settings (not GPS). Used solely to determine the correct currency for displaying coin purchase prices. We do **not** request location permissions.
- **Platform type** (Android, iOS, Web) — Used to route you to the correct payment method (App Store/Play Store vs. Razorpay).
- **Authentication session tokens** — Managed by Supabase to keep you signed in securely.

### 3.6 Data Stored Locally on Your Device

We use **SharedPreferences** (simple key-value storage on your device) to store:

| Key | Purpose |
|-----|---------|
| `onboarding_done` | Remembers whether you've completed onboarding so you aren't shown it again |
| `theme_mode` | Remembers your light/dark/system theme preference |
| `pwa_banner_seen_*` | (Web only) Remembers if you've seen the PWA install prompt so it doesn't repeat |

This data never leaves your device, is not synced to our servers, and is deleted when you uninstall the App.

---

## 4. How We Use Your Information

We use the data described above **exclusively** for these purposes:

1. **Providing the service** — Creating and managing your account, displaying dares and performer posts, processing submissions, and facilitating the coin economy.
2. **Processing payments** — Creating purchase orders, verifying payment signatures server-side, and crediting coins to your wallet.
3. **Processing withdrawals** — Sending your earned coins as real currency to your UPI ID.
4. **Delivering notifications** — Informing you of dare activity (claims, submissions, approvals, payouts) via in-app notifications.
5. **Content moderation** — Submitted dare proof may be analyzed by server-side AI moderation (using Google Gemini, called exclusively from our backend — never from your device) to detect harmful content. This is done to keep the community safe.
6. **Account management** — Password resets, account disablement/recovery, and deletion.

We do **not** use your data for:
- Advertising or ad targeting
- Behavioral profiling or analytics
- Selling or renting to third parties
- Training AI/ML models on your personal content

---

## 5. Third-Party Services

We use a limited number of third-party services. Here is exactly what each one receives:

### 5.1 Supabase (Backend & Database)

- **What it receives:** All account data, profile data, dares, posts, transactions, notifications, and uploaded media (avatars, proof videos).
- **Purpose:** Supabase is our backend-as-a-service provider. It hosts our database, authentication system, file storage, and server-side edge functions.
- **Privacy:** [Supabase Privacy Policy](https://supabase.com/privacy)

### 5.2 Firebase (Google)

- **What it receives:** Basic app initialization data (project ID, app ID).
- **Purpose:** Firebase is used **solely** for initializing the Google Sign-In SDK. We do **not** use Firebase Analytics, Firebase Crashlytics, Firebase Cloud Messaging, or any other Firebase service that collects behavioral or usage data.
- **Privacy:** [Google Privacy Policy](https://policies.google.com/privacy)

### 5.3 Google Sign-In

- **What it receives:** Your Google account email, display name, and profile photo URL during the OAuth flow.
- **Purpose:** Optional alternative sign-in method. We receive only an ID token to verify your identity.
- **Privacy:** [Google Privacy Policy](https://policies.google.com/privacy)

### 5.4 RevenueCat (Mobile Payments)

- **What it receives:** An anonymous app user ID and purchase receipts from the App Store/Play Store.
- **Purpose:** Manages in-app purchases on Android and iOS. Validates purchase receipts and triggers coin crediting.
- **What it does NOT receive:** Your email, username, profile, or any personal information beyond what Apple/Google provides with the receipt.
- **Privacy:** [RevenueCat Privacy Policy](https://www.revenuecat.com/privacy/)

### 5.5 Razorpay (Web Payments)

- **What it receives:** Order amount, currency, and your payment details (entered directly into Razorpay's secure widget — we never see them).
- **Purpose:** Processes coin purchases on Web and Desktop, and as a fallback on sideloaded Android apps.
- **What we receive back:** Order ID, payment ID, and a cryptographic signature — used solely for server-side verification.
- **Privacy:** [Razorpay Privacy Policy](https://razorpay.com/privacy/)

### 5.6 Google Fonts

- **What it receives:** Standard HTTP requests to load font files.
- **Purpose:** Rendering the App's typography. Google Fonts does not use cookies or collect personal data beyond standard server logs.
- **Privacy:** [Google Fonts Privacy FAQ](https://developers.google.com/fonts/faq/privacy)

### 5.7 Google Gemini (Server-Side Only)

- **What it receives:** Dare descriptions and proof submission content sent from our backend edge functions (never directly from your device).
- **Purpose:** AI-powered content moderation to detect harmful or inappropriate content.
- **Note:** Your personal account information (email, username, etc.) is not sent to Gemini — only the content being moderated.
- **Privacy:** [Google AI Privacy](https://policies.google.com/privacy)

---

## 6. Permissions We Request

### Android

| Permission | Why We Need It |
|-----------|---------------|
| **INTERNET** | Required for all network communication with our backend |
| **CAMERA** | Allows you to take profile pictures and record dare proof videos |
| **RECORD_AUDIO** | Required when recording video with audio for dare proof submissions |
| **READ_EXTERNAL_STORAGE** (Android 12 and below only) | Allows you to select existing photos/videos from your gallery for profile pictures or dare proof |
| **WRITE_EXTERNAL_STORAGE** (Android 12 and below only) | Allows saving dare proof media to your device gallery |

### iOS

| Permission | Why We Need It |
|-----------|---------------|
| **Camera Usage** (`NSCameraUsageDescription`) | Take profile pictures and record dare proof videos |
| **Microphone Usage** (`NSMicrophoneUsageDescription`) | Record audio when filming dare proof videos |
| **Photo Library Usage** (`NSPhotoLibraryUsageDescription`) | Pick existing photos/videos for profile pictures or dare proof uploads |
| **Photo Library Add Usage** (`NSPhotoLibraryAddUsageDescription`) | Save dare completion media to your photo library |

**Permissions we do NOT request:**
- ❌ Location / GPS
- ❌ Contacts / Address Book
- ❌ Calendar
- ❌ Bluetooth
- ❌ Phone / Call Logs
- ❌ Background App Refresh (for tracking)
- ❌ Push Notification tracking tokens (notifications are in-app only via Supabase Realtime)

---

## 7. Data Retention

| Data Type | Retention Period |
|-----------|-----------------|
| **Account & profile data** | Retained while your account is active. Permanently deleted 90 days after you request account deletion. |
| **Dares, posts, and submissions** | Retained while your account is active. Removed upon permanent account deletion. |
| **Proof videos** | Auto-deleted from storage 30 days after the dare is settled, per our internal policy. |
| **Transaction records** | Retained for the lifetime of your account for your records and for legal/financial compliance. Deleted upon permanent account deletion. |
| **Notifications** | Stored until deleted or until account deletion. |
| **Local device data** (SharedPreferences) | Deleted when you uninstall the App or clear app data. |

---

## 8. Data Security

We take the security of your data seriously:

- **Encryption in transit:** All communication between the App and our servers uses HTTPS/TLS encryption.
- **Encryption at rest:** Our database and file storage are hosted on Supabase's infrastructure, which encrypts data at rest.
- **Password hashing:** Passwords are salted and hashed using industry-standard algorithms (bcrypt via Supabase Auth). We never store or have access to plaintext passwords.
- **Row-Level Security (RLS):** Our database uses Supabase Row-Level Security policies, ensuring users can only access their own private data (wallet, transactions, notifications).
- **Server-side verification:** All financial transactions (coin purchases, withdrawals) are verified server-side via edge functions. The Flutter client never directly modifies wallet balances.
- **Signed URLs:** Proof videos are accessed via time-limited signed URLs (15-minute expiry) rather than permanent public links.
- **No client-side secrets:** Sensitive API keys (Razorpay secret, Gemini key) are stored exclusively on the server and never embedded in the App.

---

## 9. Your Rights

You have the following rights regarding your data:

- **Access:** You can view your profile data, wallet balance, and transaction history directly within the App at any time.
- **Correction:** You can update your display name, bio, and profile photo from the Settings screen.
- **Deletion:** You can request account deletion from Settings → "Delete Account." Your account will be disabled immediately and permanently deleted after a 90-day grace period. During this period, you can sign back in and cancel the deletion.
- **Data Portability:** If you would like a copy of your data, contact us at «Contact Email» and we will provide it in a standard format within 30 days.
- **Withdraw Consent:** You can revoke Google Sign-In access from your Google Account settings at any time. You can sign out and stop using the App at any time.

To exercise any of these rights, contact us at **«Contact Email»**.

---

## 10. Children's Privacy

«App Name» is not intended for children under the age of **13** (or the minimum age required by applicable law in your jurisdiction). We do not knowingly collect personal information from children. If you are a parent or guardian and believe your child has provided us with personal data, please contact us at «Contact Email» and we will promptly delete it.

---

## 11. Cookies & Tracking

- The **mobile app** does not use cookies.
- The **web version** does not use tracking cookies, advertising cookies, or analytics cookies. The only local storage used is the SharedPreferences data described in Section 3.6, which is purely functional (theme preference, onboarding state, PWA banner state).
- We do **not** use any analytics platforms (no Google Analytics, Firebase Analytics, Mixpanel, Amplitude, Sentry, or similar services).

---

## 12. International Data Transfers

Our backend infrastructure is hosted by Supabase. Your data may be stored and processed in data centers outside your country of residence. When this occurs, we rely on Supabase's infrastructure safeguards and standard contractual protections to ensure your data remains protected.

---

## 13. Changes to This Policy

We may update this Privacy Policy from time to time. When we make changes:

- The "Last Updated" date at the bottom will be revised.
- For material changes that affect how we handle your data, we will notify you via an in-app notification before the changes take effect.
- Continued use of the App after changes constitutes your acceptance of the revised policy.

We encourage you to review this policy periodically.

---

## 14. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us:

- **Email:** «Contact Email»
- **Developer:** «Company Name»

We aim to respond to all privacy-related inquiries within **7 business days**.

---

**Last Updated:** «Last Updated Date»
