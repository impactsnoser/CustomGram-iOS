# CustomGram: GitHub + IPA через Actions

## Что получится

| Workflow | Артефакт | Нужен Apple Developer ($99)? |
|---|---|---|
| `customgram-official-ios.yml` | Сборка **симулятора** (проверка компиляции) | Нет |
| `customgram-build-ipa.yml` | **CustomGram.ipa** (fake/unsigned signing) | Нет для CI-артефакта* |

\* IPA из CI подписан **fake codesigning** (как у официального Telegram-iOS CI). На реальный iPhone обычно ставят через **Xcode → Personal Team** или платный Developer Program для TestFlight/App Store.

---

## Шаг 1. Репозиторий на GitHub

**Рекомендуется:** форк официального репозитория, чтобы submodules подтягивались в Actions:

1. Откройте https://github.com/TelegramMessenger/Telegram-iOS  
2. **Fork** → ваш аккаунт  
3. Клонируйте **свой форк** на Mac (не zip-архив):

```bash
git clone --recursive https://github.com/YOUR_USER/Telegram-iOS.git
cd Telegram-iOS
```

4. Перенесите изменения CustomGram из этой папки (модули `submodules/CustomGramCore`, `submodules/CustomGramUI`, патчи, `customgram/`) в клон и закоммитьте.

**Если пушите текущую папку с Windows:** в корне должен быть `git init` и remote на GitHub. Submodules с URL вида `../rlottie.git` работают только внутри организации Telegram — для отдельного репозитория лучше форк upstream.

---

## Шаг 2. Secrets в GitHub

`Settings` → `Secrets and variables` → `Actions` → **New repository secret**:

| Secret | Значение |
|---|---|
| `CUSTOMGRAM_API_ID` | Число с https://my.telegram.org/apps |
| `CUSTOMGRAM_API_HASH` | Hash с той же страницы |

Без них workflow `customgram-build-ipa` завершится с ошибкой.

---

## Шаг 3. Push кода

```bash
git add .
git commit -m "CustomGram: power-user layer + CI IPA workflow"
git push -u origin main
```

При push в `main`/`master` запустится сборка IPA (можно отключить, оставив только `workflow_dispatch`).

---

## Шаг 4. Запуск сборки вручную

1. GitHub → ваш репозиторий → **Actions**  
2. **CustomGram Build IPA** → **Run workflow**  
3. Дождитесь ~1–3 часа (первая сборка Bazel долгая)  
4. Внизу run → **Artifacts** → скачайте `CustomGram-ipa-NNN.zip` → внутри `CustomGram.ipa`

Параллельно можно гонять **CustomGram Free Simulator Build** — быстрее проверить, что код компилируется.

---

## Шаг 5. Установка на iPhone

### Бесплатно (Personal Team)

1. Mac + Xcode (версия из `versions.json`)  
2. Сгенерировать проект:

```bash
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  generateProject \
  --configurationPath=customgram/development-configuration.json \
  --disableProvisioningProfiles
```

3. Открыть `.xcodeproj`, Signing → ваш Apple ID (Personal Team)  
4. Подключить iPhone → Run  

### IPA из Actions

Fake-signed IPA **не равен** App Store / TestFlight. Для распространения нужен платный Apple Developer Program и настройка signing в CI (отдельная задача).

---

## Локальная проверка перед push

Только на **macOS**:

```bash
# Симулятор (быстрее)
python3 build-system/Make/Make.py \
  --cacheDir="$HOME/telegram-bazel-cache" \
  build \
  --configurationPath=customgram/development-configuration.json \
  --configuration=debug_sim_arm64 \
  --disableProvisioningProfiles \
  --overrideXcodeVersion
```

---

## Частые ошибки CI

| Ошибка | Решение |
|---|---|
| Submodule clone failed | Используйте **fork** `TelegramMessenger/Telegram-iOS`, не голый zip |
| Secrets missing | Добавьте `CUSTOMGRAM_API_ID` / `CUSTOMGRAM_API_HASH` |
| Xcode version | Workflow использует `--overrideXcodeVersion`; при сбое сверьте `versions.json` с runner image |
| IPA not found | Смотрите лог шага `Build release IPA` — ошибка Bazel раньше сбора артефакта |
