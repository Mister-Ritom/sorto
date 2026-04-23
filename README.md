# ⚡ Sorto — Dare to earn.

A two-sided social dare platform where users post cash-backed challenges and performers earn real money completing them — with AI moderation and atomic financial transactions.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-0075FF)](https://riverpod.dev)

---

## What is Sorto?

Sorto connects two types of users:

- **Posters** — People who want to see something done. They lock real money (as SortCoins) into a dare.
- **Performers** — People who do it, submit video proof, and earn 80% of the bounty when approved.

All financial logic runs server-side via Supabase Edge Functions. The client app is **read-only for wallets** — no client-side coin mutations ever.

---

## Features

| Feature                        | Description                                                    |
| ------------------------------ | -------------------------------------------------------------- |
| 🎯 **Dare Feed**               | Filterable, paginated feed of open dares by category and mode  |
| 🎬 **Performer Posts**         | Creators list themselves — funders create dares from their ads |
| 💰 **SortCoin Wallet**         | In-app economy with escrow, earnings, and withdrawal tracking  |
| 🤖 **AI Moderation**           | Gemini Flash auto-reviews video proof for harm/completion      |
| 📲 **Deep Linking**            | `sorto.ritom.in/dare/:id` and `/profile/:username` open in-app |
| 🔔 **Real-time Notifications** | Supabase Realtime streams for all dare events                  |
| 🌗 **Dark & Light Modes**      | Full system-adaptive theme with bento-aesthetic                |
| 🔐 **Secure Transactions**     | Atomic SQL functions + Edge Functions enforce the Iron Rule    |

---

## Tech Stack

```
Flutter (Dart 3)
├── flutter_riverpod 3     — State management (Notifier API)
├── go_router 17           — Navigation & deep linking
├── supabase_flutter 2     — Auth, Realtime, Storage, Edge Functions
├── flutter_animate 4      — Micro-animations
├── video_player / camera  — Proof video playback & capture
├── razorpay_flutter       — Web payments (India)
├── purchases_flutter      — Native IAP via RevenueCat
└── google_fonts           — Syne + DM Sans typography

Supabase (Backend)
├── PostgreSQL             — Core data store with RLS
├── Deno Edge Functions    — Atomic financial transactions
├── Supabase Storage       — Proof videos + avatars
└── Supabase Realtime      — Notifications + wallet streams
```

---

## Project Structure

```
sorto/
├── lib/
│   ├── core/
│   │   ├── constants/        # Business rules, coin packs, categories, API names
│   │   ├── router/           # GoRouter config + deep link setup
│   │   ├── services/         # Single Supabase client wrapper
│   │   ├── theme/            # Colors, typography, ThemeData factories
│   │   └── utils/            # Formatters, validators
│   ├── features/
│   │   ├── auth/             # Sign in, Sign up, Forgot password
│   │   ├── onboarding/       # 8-step psychology-driven onboarding flow
│   │   ├── feed/             # Home feed, search, Bento creator grid
│   │   ├── dares/            # Dare detail, create, submit proof, review
│   │   ├── performer_posts/  # Creator ads: create + detail/fund
│   │   ├── wallet/           # Balance, transaction history, withdrawal
│   │   ├── profile/          # Own profile + public profile
│   │   ├── notifications/    # Real-time notification stream
│   │   └── admin/            # Contest queue for disputed dares
│   └── shared/
│       ├── models/           # Dare, Profile, Wallet, Transaction, ...
│       └── widgets/          # DareCard, CoinChip, BentoGrid, skeletons, ...
│
└── supabase/
    ├── migrations/
    │   ├── 001_schema.sql        # Core tables
    │   ├── 002_rls.sql           # Row Level Security policies
    │   ├── 003_functions.sql     # DB triggers (auto-profile, stats)
    │   ├── 004_indexes.sql       # Performance indexes
    │   └── 005_wallet_updates.sql # Atomic coin RPCs
    └── functions/
        ├── dare-create/          # Lock bounty coins into escrow
        ├── dare-claim/           # Performer claims a solo dare
        ├── dare-submit-proof/    # Upload proof + Gemini AI moderation
        ├── dare-settle/          # Poster approves/rejects → payout
        ├── withdrawal-initiate/  # Request real-money withdrawal
        ├── performer-post-create/ # List a performer ad
        └── performer-post-fund/   # Fund an ad → auto-create locked dare
```

---

## Getting Started

### Prerequisites

- Flutter SDK
- A [Supabase](https://supabase.com) project
- A [RevenueCat](https://revenuecat.com) account (IAP)
- A [Razorpay](https://razorpay.com) account (web payments, India)
- Gemini API key (proof moderation, server-side only)

### 1. Clone & install

```bash
git clone https://github.com/yourorg/sorto.git
cd sorto
flutter pub get
```

### 2. Configure credentials

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
static const String razorpayKeyId  = 'rzp_live_XXXX';
static const String revenuecatAppleKey  = 'appl_XXXX';
static const String revenuecatGoogleKey = 'goog_XXXX';
```

### 3. Run database migrations

In the Supabase SQL Editor, run each file in order:

```
001_schema.sql → 002_rls.sql → 003_functions.sql → 004_indexes.sql → 005_wallet_updates.sql
```

Or via Supabase CLI:

```bash
supabase db push
```

### 4. Deploy Edge Functions

```bash
supabase functions deploy dare-create
supabase functions deploy dare-claim
supabase functions deploy dare-submit-proof
supabase functions deploy dare-settle
supabase functions deploy withdrawal-initiate
supabase functions deploy performer-post-create
supabase functions deploy performer-post-fund
```

### 5. Set secrets

```bash
supabase secrets set GEMINI_API_KEY=your_gemini_key
# SUPABASE_SERVICE_ROLE_KEY and SUPABASE_URL are injected automatically
```

### 6. Create storage buckets

| Bucket         | Access                              |
| -------------- | ----------------------------------- |
| `proof-videos` | Private (signed URL, 15 min expiry) |
| `avatars`      | Public                              |

### 7. Run the app

```bash
flutter run
```

---

## Environment Variables

| Variable                    | Location             | Purpose                              |
| --------------------------- | -------------------- | ------------------------------------ |
| `SUPABASE_URL`              | `api_constants.dart` | Project endpoint                     |
| `SUPABASE_ANON_KEY`         | `api_constants.dart` | Client-safe public key               |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Secrets     | Edge Function auth (never in client) |
| `GEMINI_API_KEY`            | Supabase Secrets     | AI moderation (never in client)      |
| `RAZORPAY_KEY_ID`           | `api_constants.dart` | Web payment gateway                  |
| `REVENUECAT_APPLE_KEY`      | `api_constants.dart` | iOS native IAP                       |
| `REVENUECAT_GOOGLE_KEY`     | `api_constants.dart` | Android native IAP                   |

---

## Deep Linking

| URL                                | Opens                 |
| ---------------------------------- | --------------------- |
| `sorto.ritom.in/dare/:id`          | Dare detail screen    |
| `sorto.ritom.in/post/:id`          | Performer post detail |
| `sorto.ritom.in/profile/:username` | Public profile        |

**iOS** — Add `CFBundleURLSchemes: [sorto]` to `Info.plist` and enable `Associated Domains → applinks:sorto.ritom.in`.

**Android** — Add an `intent-filter` for `https://sorto.ritom.in` in `AndroidManifest.xml` with `android:autoVerify="true"`.

---

## The Iron Rule

> **The client app never writes to `wallets` or `transactions` directly.**

RLS on `wallets` and `transactions` blocks all `INSERT`/`UPDATE`/`DELETE` from authenticated users. Only the service role (inside Edge Functions) can mutate financial state.

```
Client → supabase.functions.invoke('dare-create')
       → Edge Function checks auth + balance
       → SQL RPC atomically escrows coins + creates dare
       → Returns dare object to client
```

---

## Coin Economics

| Action               | Rate                         |
| -------------------- | ---------------------------- |
| Buy (native IAP)     | ~₹1.49 / coin                |
| Buy (Razorpay web)   | ~₹1.24 / coin                |
| Dare bounty escrowed | 100% locked until settled    |
| Performer payout     | 80% of bounty                |
| Platform fee         | 20% of bounty                |
| Withdraw             | ₹1 / coin via UPI (min ₹100) |

---

## License

MIT © 2026 Ritom

---

_Built with ⚡ by [ritom](https://ritom.in)_
