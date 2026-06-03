# Cursor Next Steps

Open this folder in Cursor:

`work/Telegram-iOS-official`

Then continue in this order:

1. Replace only the Telegram API placeholders in `customgram/development-configuration.json`.
2. Generate the Xcode project:

```sh
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  generateProject \
  --configurationPath=customgram/development-configuration.json \
  --disableProvisioningProfiles
```

3. For a free CI/simulator build, run:

```sh
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  build \
  --configurationPath=customgram/development-configuration.json \
  --configuration=debug_sim_arm64 \
  --disableProvisioningProfiles
```

4. To install on your own iPhone for free, use Xcode with your free Apple Account / Personal Team.
5. Build the generated project once before deep UI edits.
6. Implement the customization layer inside Telegram's existing theme and presentation-data system.
7. Add each UI customization as a small patch with a rollback path.

The earlier standalone SwiftUI prototype is not the real client. Treat it only as a visual sketch if needed.
