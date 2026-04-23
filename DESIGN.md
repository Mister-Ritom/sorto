# Sorto — Design System

> The visual and interaction language of the Sorto platform. This document is the single source of truth for all design decisions — from colors to motion to component anatomy.

---

## 1. Design Philosophy

Sorto is a **high-energy, high-stakes** product. Every design decision reinforces three principles:

### 1.1 Alive
The interface must feel responsive. Static screens kill engagement on a dare platform. Every tap gets haptic feedback. Every state change animates. Money moving in and out of wallets is always dramatised.

### 1.2 Premium
Sorto handles real money. Users must trust it. The aesthetic is **dark-first, editorial, confident** — not playful, not pastel, not generic. Think Bloomberg Terminal meets Duolingo's energy.

### 1.3 Honest
Financial information is always visible and never buried. Coin balances, platform fees, escrow locks, and payout percentages are surfaced clearly. No dark patterns.

---

## 2. Color System

All colors are defined in `lib/core/theme/app_colors.dart`.

### 2.1 Brand Palette

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#A855F7` | CTA buttons, active states, links, brand moments |
| `primaryDim` | `#7C3AED` | Button press states, darker accents |
| `primaryLight` | `#D8B4FE` | Chips on dark bg, tinted highlights |
| `accent` | `#F97316` | Secondary CTA, dare mode badges (Solo), gradient end |
| `accentDim` | `#EA580C` | Accent press state |
| `accentLight` | `#FDBA74` | Warm tints on dark surfaces |

**Brand gradient** (left → right): `#A855F7 → #F97316`

Used on: logo mark, hero text shader, primary button fill, coin burst particles, launch screen typewriter, avatar placeholder ring.

### 2.2 Dark Mode Surface Stack

The dark theme uses a layered surface system. Each layer is subtly lighter than the one beneath it, creating perceived depth without borders.

```
darkBackground  #080808  ← Scaffold, bottom nav
darkSurface     #111111  ← AppBar, modal bottom sheets
darkCard        #1A1A1A  ← Cards, input fields, chips
darkCardBorder  #2A2A2A  ← Subtle dividers, card outlines
```

### 2.3 Light Mode Surface Stack

Light mode is **lavender-tinted**, not plain white — keeping the brand personality intact.

```
lightBackground  #F5F0FF  ← Scaffold
lightSurface     #FFFFFF  ← AppBar, modals
lightCard        #F0ECF9  ← Cards, fields
lightCardBorder  #E0D8F5  ← Borders
```

### 2.4 Semantic Colors

| Token | Hex | Usage |
|---|---|---|
| `success` | `#22C55E` | Dare approved, payout credited |
| `error` | `#EF4444` | Rejection, validation failures, insufficient balance |
| `warning` | `#FACC15` | AI harm warning banners |
| `info` | `#38BDF8` | Neutral informational states |

### 2.5 Financial Colors

| Token | Hex | Usage |
|---|---|---|
| `coinGold` | `#FFD700` | Coin amounts everywhere |
| `coinGoldDim` | `#F59E0B` | Gradient end for coin chip |
| `escrowPurple` | `#A855F7` | Escrowed/locked balance |
| `earnedGreen` | `#22C55E` | Withdrawable earnings |

### 2.6 Dare Mode Colors

| Mode | Color | Hex |
|---|---|---|
| Solo | Orange | `#F97316` |
| Split | Purple | `#A855F7` |
| Best | Gold | `#FFD700` |

### 2.7 Glassmorphism

Glass effects are used sparingly on overlaid elements (e.g., bottom sheets over video).

| Token | Value |
|---|---|
| `glassDark` | `white @ 5% opacity` |
| `glassLight` | `white @ 60% opacity` |
| `glassBorderDark` | `white @ 10% opacity` |
| `glassBorderLight` | `white @ 30% opacity` |

---

## 3. Typography

All type is defined in `lib/core/theme/app_typography.dart`.

### 3.1 Font Families

| Role | Font | Weights | Personality |
|---|---|---|---|
| **Display / Editorial** | [Syne](https://fonts.google.com/specimen/Syne) | 700, 800 | Bold, tight, confident |
| **Body / UI** | [DM Sans](https://fonts.google.com/specimen/DM+Sans) | 400, 600, 700 | Clean, legible, modern |

### 3.2 Type Scale

#### Display (Syne — editorial moments)

| Token | Size | Weight | Letter-spacing | Usage |
|---|---|---|---|---|
| `displayXL` | 52px | 800 | -1.5 | Splash/onboarding hero |
| `displayL` | 40px | 800 | -1.2 | Section headers |
| `displayM` | 32px | 700 | -0.8 | Wallet balance |
| `displayS` | 22px | 700 | -0.5 | Logo wordmark, card titles |

#### Heading (DM Sans — structured UI)

| Token | Size | Weight | Usage |
|---|---|---|---|
| `headingL` | 22px | 700 | Profile name, dare title |
| `headingM` | 18px | 600 | AppBar titles, section titles |
| `headingS` | 16px | 600 | Card subtitles, tab labels |

#### Body (DM Sans — readable content)

| Token | Size | Weight | Line-height | Usage |
|---|---|---|---|---|
| `bodyL` | 16px | 400 | 1.5 | Dare descriptions |
| `bodyM` | 14px | 400 | 1.5 | Secondary text, captions |
| `bodyS` | 12px | 400 | 1.5 | Timestamps, meta info |

#### Labels (DM Sans — data & badges)

| Token | Size | Weight | Usage |
|---|---|---|---|
| `labelL` | 14px | 600 | Stats, badge text |
| `labelM` | 12px | 600 | Filter chips |
| `labelS` | 10px | 600 | Mode tags (uppercase) |

#### Special

| Token | Description |
|---|---|
| `typewriter` | Syne 34px/800 — launch screen animated phrases |
| `usernameDisplay` | Syne 28px/700 — creator card overlay |
| `coinAmount` | DM Sans 20px/700, gold — inline coin values |
| `coinAmountLarge` | Syne 32px/800, gold — wallet balance hero |

---

## 4. Spacing & Layout

### 4.1 Grid

- **Base unit**: `4px`
- **Screen padding**: `16px` (horizontal), `24px` (top)
- **Card padding**: `16px` (standard), `20px` (featured)
- **Section gap**: `24px`
- **Item gap**: `10–12px`

### 4.2 Border Radius

| Context | Radius |
|---|---|
| Buttons (large) | `14px` |
| Cards | `16px` |
| Chips / badges | `100px` (pill) |
| Modals | `24px` (top corners only) |
| Avatars | `50%` (circle) |
| Logo mark | `22px` |
| Input fields | `12px` |

### 4.3 Elevation

Sorto avoids Material shadow-based elevation. Depth is expressed through:
1. **Color layering** — lighter surfaces sit "above" darker ones
2. **Borders** — subtle `1px` borders at `darkCardBorder` tone
3. **Blur** (glass effects only) — `BackdropFilter` on modal overlays

---

## 5. Iconography

All icons come from **Material Icons Rounded** (`Icons.*_rounded`). Rounded corners match the app's overall softness despite the dark aesthetic.

| Icon usage | Style |
|---|---|
| Navigation | Rounded, 24px, `primary` when active |
| Action buttons | Rounded, 24px |
| Badges / status | Rounded, 16px |
| CTA arrows | `Icons.arrow_forward_ios_rounded` |

---

## 6. Component Anatomy

### 6.1 Dare Card

```
┌────────────────────────────────────────────────────┐
│  [Category Emoji]  [Mode Badge]       [Status Chip]│
│                                                    │
│  Title (headingS, 2 lines max)                     │
│  Description preview (bodyS, 2 lines)              │
│                                                    │
│  [@posterUsername]      [🪙 bounty]   [⏰ expires] │
└────────────────────────────────────────────────────┘
```

- Background: `darkCard` / `lightCard`
- Border: `1px` at `darkCardBorder`
- Radius: `16px`
- On press: scale to `0.97`, haptic `lightImpact`
- Animation: staggered `fadeIn + slideUp` with `50ms` delay per card

### 6.2 Coin Chip (Header Widget)

```
[🪙 icon] [amount in gold text] → taps to Wallet screen
```

- Background: `coinGold @ 10% opacity`
- Border: `coinGold @ 30% opacity`
- Text: `labelL` in `coinGold`
- Pulsing animation when balance updates

### 6.3 SortoButton

Three variants:

| Variant | Fill | Border | Text |
|---|---|---|---|
| `filled` (default) | Brand gradient | None | White |
| `outline` | Transparent | `primary` 1px | `primary` |
| `danger` | `error @ 15%` | `error` 1px | `error` |

- Height: `56px` (default), `44px` (compact)
- Radius: `14px`
- On press: scale `0.96` + haptic `mediumImpact`
- Loading: `SizedBox(16px)` spinner centred

### 6.4 Dare Mode Badge

Inline pill badge with mode-specific color:

```
[● Solo]   — orange background @ 20%, orange text
[● Split]  — purple background @ 20%, purple text
[● Best]   — gold background @ 20%, gold text
```

### 6.5 Bento Grid (Trend Creators Tab)

A staggered masonry layout using `flutter_staggered_grid_view`:

- 2-column base
- Cards have variable heights based on aspect ratio
- First card in every 5 spans full width ("hero" slot)
- Each card: avatar + username overlay (glassmorphism gradient)
- On tap: navigates to `PerformerPostDetailScreen`

### 6.6 Skeleton Loaders

All async screens show animated shimmer skeletons matching the expected layout. Implemented with `shimmer` package and `ShimmerBox` / `ShimmerAvatar` shared widgets.

---

## 7. Motion & Animation

All animation durations and curves are defined in `AppConstants`.

### 7.1 Page Transitions

| Transition | Used for | Duration |
|---|---|---|
| `_slideUpPage` | Modals, create flows | 350ms, `easeOutCubic` |
| `_slidePage` | Lateral navigation | 300ms, `easeOutCubic` |
| `_fadePage` | Auth screens, splash | 300ms, `linear` |

### 7.2 Micro-interactions

| Interaction | Animation | Duration |
|---|---|---|
| Card tap | Scale `1.0 → 0.97 → 1.0` | 150ms |
| Button press | Scale `1.0 → 0.96 → 1.0` | 150ms |
| Category chip select | Background/border color fade | 200ms |
| Coin balance update | Counter roll (implicit) | 400ms |
| Verdict reveal (approve/reject) | Scale + fade with bounce | 600ms |

### 7.3 Entry Animations (flutter_animate)

Standard stagger pattern for list items:

```dart
// Card at index i
.animate(delay: Duration(milliseconds: i * 50))
.fadeIn(duration: 400.ms)
.slideY(begin: 0.05, end: 0.0)
```

Standard hero entry (profile avatar, logo):

```dart
.animate()
.scale(curve: Curves.elasticOut, duration: 600.ms)
```

### 7.4 Coin Burst

`AnimatedCoinBurst` fires on the launch screen CTA tap — a particle explosion of `🪙` emoji that scales, spreads, and fades. Controlled by `AnimatedCoinBurstController`.

### 7.5 Typewriter Effect

Used on the launch screen to build psychological investment before signup. Three phrases typed sequentially:

```
"Your dares."
"Your money."
"Your rules."
```

Each character types at `60ms` intervals. Completed phrases stay on screen and shimmer with the brand gradient. A blinking `3px` cursor follows the active line.

---

## 8. Onboarding Flow

8 screens, each with a distinct psychological purpose:

| # | Screen | Purpose |
|---|---|---|
| 1 | **Hook** | Loss-aversion hook — "Are you the one who posts or performs?" |
| 2 | **Role** | Role selection with clear value props for each path |
| 3 | **Interests** | Category interest selection — personalises the feed |
| 4 | **Social Proof** | Real-looking stats and testimonials — builds trust |
| 5 | **Username** | Identity investment — picking a name creates ownership |
| 6 | **Notifications** | Framed as "Never miss a dare" — permission priming |
| 7 | **Wallet Intro** | Explains the coin system, fees, and escrow simply |
| 8 | **Launch** | Typewriter CTA — emotional close before home feed |

All screens use `_slideUpPage` transitions to feel like a single flowing experience, not a form.

---

## 9. Screen-by-Screen Notes

### Home Screen
- `NestedScrollView` with `SliverAppBar` (floating + snap)
- Tab 1: Dare Feed — paginated, category-filtered
- Tab 2: Trend Creators — Bento grid of performer posts
- FAB: `+` → Create Dare, elastic bounce entry on load

### Dare Detail Screen
- Header: category + mode + status + bounty (prominent)
- Body: full description, tags, poster info
- Action zone: context-sensitive — claim / submit proof / review proof / re-open
- Expiry countdown if dare is still open

### Wallet Screen
- Balance hero: `displayM` Syne, gold gradient text
- 3 balance states shown: spendable / escrowed / withdrawable
- Transaction list: grouped by type, direction-coloured (credit = green, debit = muted)
- Filter chips by transaction type

### Notifications Screen
- Real-time stream from Supabase
- Unread badge on home screen nav icon
- Tap: marks as read + navigates to relevant dare/post
- "Mark all read" action in AppBar

---

## 10. Theming Architecture

```
SortoApp (MaterialApp.router)
└── theme:        AppTheme.dark()
    themeMode:    ThemeMode.system (follows OS preference)
    darkTheme:    AppTheme.dark()
    theme:        AppTheme.light()
```

`AppTheme.dark()` and `AppTheme.light()` both use:
- `AppColors.darkColorScheme()` / `AppColors.lightColorScheme()`
- `AppTypography.buildTextTheme(dark: true/false)`
- Consistent `AppBarTheme`, `CardTheme`, `InputDecorationTheme`, `TabBarTheme`, `FloatingActionButtonTheme`

Screens access brightness via:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

And choose surface colors as:
```dart
color: isDark ? AppColors.darkCard : AppColors.lightCard
```

---

## 11. Accessibility

- All tap targets are minimum `44×44px`
- Color contrast ratios meet WCAG AA on both dark and light themes
- Semantic labels on all icon buttons
- `HapticFeedback` is used contextually — light for selections, medium for CTAs
- No information is conveyed by color alone (badges always include text)

---

## 12. File Reference

| File | Contents |
|---|---|
| `lib/core/theme/app_colors.dart` | Full color palette, gradients, ColorScheme factories |
| `lib/core/theme/app_typography.dart` | All text styles, TextTheme builder |
| `lib/core/theme/app_theme.dart` | ThemeData factories (dark + light) |
| `lib/core/constants/app_constants.dart` | Animation durations, business rules |
| `lib/shared/widgets/sorto_button.dart` | Button component (3 variants) |
| `lib/shared/widgets/coin_chip.dart` | Animated coin balance widget |
| `lib/shared/widgets/dare_mode_badge.dart` | Mode + status badge components |
| `lib/shared/widgets/skeleton_loader.dart` | Shimmer skeleton variants |
| `lib/shared/widgets/animated_coin.dart` | Coin burst particle effect |
| `lib/features/feed/widgets/dare_card.dart` | Dare card component |
| `lib/features/feed/widgets/bento_grid.dart` | Staggered creator grid |
| `lib/features/profile/widgets/profile_widgets.dart` | Shared profile UI components |
