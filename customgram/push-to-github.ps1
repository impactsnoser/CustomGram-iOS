# Заливка CustomGram на GitHub через PowerShell
# Использование:
#   .\customgram\push-to-github.ps1 -RepoUrl "https://github.com/USER/CustomGram-iOS.git"
#   .\customgram\push-to-github.ps1 -RepoUrl "https://github.com/USER/CustomGram-iOS.git" -FullTree

param(
    [Parameter(Mandatory = $true)]
    [string] $RepoUrl,

    [switch] $FullTree,
    [string] $Branch = "main"
)

$ErrorActionPreference = "Stop"
# Скрипт лежит в customgram/ — корень репозитория на уровень выше
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Root

Write-Host "Repository root: $Root" -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    git init -b $Branch
}

$remoteName = "origin"
$existing = git remote get-url $remoteName 2>$null
if ($LASTEXITCODE -eq 0) {
    if ($existing -ne $RepoUrl) {
        git remote set-url $remoteName $RepoUrl
    }
} else {
    git remote add $remoteName $RepoUrl
}

Write-Host "Remote: $(git remote -v)" -ForegroundColor Cyan

if ($FullTree) {
    Write-Host "Staging full tree (respecting .gitignore)..." -ForegroundColor Yellow
    git add -A
} else {
    Write-Host "Staging CustomGram patch files only..." -ForegroundColor Yellow
    $paths = @(
        ".github/workflows/customgram-build-ipa.yml",
        ".github/workflows/customgram-official-ios.yml",
        "README_CUSTOMGRAM.md",
        "customgram",
        "submodules/CustomGramCore",
        "submodules/CustomGramUI",
        "submodules/AccountUtils/BUILD",
        "submodules/AccountUtils/Sources/AccountUtils.swift",
        "submodules/TelegramCore/BUILD",
        "submodules/TelegramCore/Sources/TelegramEngine/Messages/ApplyMaxReadIndexInteractively.swift",
        "submodules/TelegramCore/Sources/TelegramEngine/Messages/DeleteMessages.swift",
        "submodules/TelegramCore/Sources/TelegramEngine/Messages/MarkAllChatsAsRead.swift",
        "submodules/TelegramCore/Sources/State/ManagedLocalInputActivities.swift",
        "submodules/TelegramCore/Sources/State/ManagedAccountPresence.swift",
        "submodules/TelegramCore/Sources/State/SynchronizePeerReadState.swift",
        "submodules/TelegramCore/Sources/State/AccountStateManagementUtils.swift",
        "submodules/TelegramCore/Sources/Account/AccountManager.swift",
        "submodules/TelegramUI/BUILD",
        "submodules/TelegramUI/Sources/SharedAccountContext.swift",
        "submodules/TelegramUI/Sources/Chat/ChatControllerOpenViewOnceMediaMessage.swift",
        "submodules/TelegramUI/Components/Chat/ChatMessageTextBubbleContentNode",
        "submodules/TelegramUI/Components/PeerInfo/PeerInfoScreen/BUILD",
        "submodules/TelegramUI/Components/PeerInfo/PeerInfoScreen/Sources/PeerInfoProfileItems.swift",
        "submodules/SettingsUI/BUILD"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { git add $p }
    }
}

$status = git status --porcelain
if ($status) {
    git -c user.email="customgram@users.noreply.github.com" -c user.name="CustomGram" `
        commit -m "CustomGram: power-user features and IPA CI workflow"
}

Write-Host "Pushing to $RepoUrl ..." -ForegroundColor Green
git push -u $remoteName $Branch

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "OK. Next steps on GitHub:" -ForegroundColor Green
    Write-Host "  1. Settings -> Secrets: CUSTOMGRAM_API_ID, CUSTOMGRAM_API_HASH"
    Write-Host "  2. Actions -> CustomGram Build IPA -> Run workflow"
} else {
    Write-Host "Push failed. Create empty repo on github.com first, then retry." -ForegroundColor Red
    exit 1
}
