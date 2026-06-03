# CustomGram on Official Telegram iOS

This repository is now based on the official open-source Telegram iOS client from `TelegramMessenger/Telegram-iOS`.

## Added in this workspace

- Downloaded the official Telegram iOS source tree.
- Switched the fork config identity from `Telegram Fork` to `CustomGram`.
- Changed the fork bundle id placeholder to `app.customgram.client`.
- Changed the fork URL scheme to `customgram`.
- Added `customgram/development-configuration.json` for Telegram's official `build-system/Make/Make.py` flow.
- Added a free GitHub Actions workflow that uses the official build system with provisioning profiles disabled.
- Added `submodules/CustomGramCore` — Keychain prefs, Ghost Mode gates, Message Vault attributes.
- Added `submodules/CustomGramUI` — settings screen and chat decoration helpers.

## Custom features implemented (CustomGram layer)

| Feature | Module | Integration point |
|---|---|---|
| Ghost Mode (no read receipts / typing / online) | `CustomGramCore` | `ApplyMaxReadIndexInteractively`, `SynchronizePeerReadState`, `ManagedLocalInputActivities`, `ManagedAccountPresence` |
| Message Vault (soft-delete + edit history) | `CustomGramCore` | `DeleteMessages.swift`, `AccountStateManagementUtils` (EditMessage) |
| Profile ID / DC viewer | `CustomGramUI` | `PeerInfoProfileItems.swift` |
| Unlimited accounts | `CustomGramCore` + `AccountUtils` | Keychain preference `unlimitedAccounts` |
| Restricted capture bypass (opt-in) | `CustomGramCore` | `ChatControllerOpenViewOnceMediaMessage.swift` |
| Settings UI | `CustomGramUI` | Own profile → **CustomGram** |

## Custom features planned (not yet done)

- Appearance Studio: theme presets, bubble radius, chat density, wallpaper presets, accent colors.
- Smart folders: Focus, Friends, Work, Broadcasts, Archived.
- Privacy blur for message previews and recent chat rows.
- Command bar for quick navigation and actions.
- Per-chat theme overrides.
- Better unread visual treatment.
- Export/import of custom theme presets.
- Visible 🗑️ badge overlay on all bubble types (text bubbles get alpha/border today).

## Source integration targets

Use Cursor search in the official tree for these areas:

- Theme and presentation data: search for `PresentationTheme`, `PresentationData`, `ThemeSettings`.
- Chat list rows: search for `ChatListItem`, `ChatListNode`, `PeerList`.
- Chat controller and message bubbles: search for `ChatController`, `ChatMessageItem`, `ChatMessageBubble`.
- Settings screens: search for `SettingsController`, `ThemeSettingsController`, `Appearance`.
- CustomGram power features: search for `CustomGramFeatureGates`, `CustomGramCore`, `CustomGramUI`.

## Important requirements

- Get your own `api_id` and `api_hash` from `https://my.telegram.org/apps`.
- Do not ship with Telegram's official app name or official paper-plane logo unless users clearly understand it is unofficial.
- Replace `PUT_YOUR_API_ID_FROM_MY_TELEGRAM_ORG` and `PUT_YOUR_API_HASH_FROM_MY_TELEGRAM_ORG` before real Telegram login/build testing.
- Build on macOS with the Xcode/Bazel versions listed in `versions.json`.
- Power-user features may conflict with Telegram ToS — all are **opt-in** in CustomGram settings.
