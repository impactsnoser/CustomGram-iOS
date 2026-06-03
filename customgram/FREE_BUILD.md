# Free Build Path

You do not need a paid Apple Developer Program membership to work on CustomGram.

## What is free

- Xcode is free.
- Telegram iOS source code is open source.
- GitHub Actions can generate/build a simulator version with `--disableProvisioningProfiles`.
- Xcode can create a free Personal Team from a normal Apple Account for personal on-device testing.

Apple's own Xcode help says that if you are not in the paid Apple Developer Program, Xcode creates a personal team for you. Apple Developer support also says you can develop for Apple platforms for free and use a Personal Team for on-device testing.

## What is not free

- App Store distribution.
- TestFlight distribution.
- Normal export/distribution IPA signing.
- Long-lived public distribution to other people's iPhones.

Those require paid Apple Developer Program signing assets.

## Free GitHub Actions build

Use `.github/workflows/customgram-official-ios.yml`.

It uses:

```sh
--disableProvisioningProfiles
--configuration=debug_sim_arm64
```

That means no Team ID is required, but the artifact is for simulator/build verification, not a ready-to-install App Store/TestFlight IPA.

## Free install on your own iPhone

Use a Mac with Xcode:

1. Open Xcode.
2. Sign in with your normal Apple Account.
3. Generate/open the Telegram Xcode project.
4. In Signing & Capabilities, choose your Personal Team.
5. Connect your iPhone.
6. Run the app from Xcode.

This is the free personal-use route. It is not the same as App Store distribution.

## Required Telegram API values

Money is not required for Telegram API credentials, but you still need your own:

- `api_id`
- `api_hash`

Get them from:

`https://my.telegram.org/apps`

Then put them in:

`customgram/development-configuration.json`
