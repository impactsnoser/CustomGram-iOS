# CustomGram Fork

This is a CustomGram fork workspace based on the official Telegram iOS source code.

The correct upstream is:

`https://github.com/TelegramMessenger/Telegram-iOS`

## What was changed

- Fork identity changed in `Telegram/Telegram-iOS/Config-Fork.xcconfig`.
- Custom build configuration added at `customgram/development-configuration.json`.
- Free-build guide added at `customgram/FREE_BUILD.md`.
- Custom feature roadmap added at `customgram/FEATURES_ADDED.md`.
- **CustomGram modules:** `submodules/CustomGramCore` (Ghost Mode, Vault, Keychain) and `submodules/CustomGramUI` (settings, chat decoration).
- Cursor continuation guide added at `customgram/CURSOR_NEXT_STEPS.md`.
- GitHub Actions workflow added at `.github/workflows/customgram-official-ios.yml`.

## Before building

Replace these Telegram API placeholders:

- `PUT_YOUR_API_ID_FROM_MY_TELEGRAM_ORG`
- `PUT_YOUR_API_HASH_FROM_MY_TELEGRAM_ORG`

No paid Apple Team ID is required for the free simulator workflow. The official Telegram iOS build still requires macOS, Xcode, Bazel, and Telegram's build system. See `README.md`, `versions.json`, and `customgram/FREE_BUILD.md`.

## GitHub → IPA

1. Добавьте secrets `CUSTOMGRAM_API_ID` и `CUSTOMGRAM_API_HASH` в репозитории GitHub.
2. Запустите workflow **CustomGram Build IPA** (или push в `main`).
3. Скачайте артефакт `CustomGram.ipa` из Actions.

Подробно: [`customgram/GITHUB_DEPLOY.md`](customgram/GITHUB_DEPLOY.md)
