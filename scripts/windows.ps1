# ==========================================================
# Windows アプリのインストール
# Wingetfile を読み込み、winget で GUI アプリを導入する
#
# 実行方法（PowerShell）:
#   make windows
#   または
#   powershell -ExecutionPolicy Bypass -File ./scripts/windows.ps1
#
# 注意:
#   このスクリプトは Windows ホスト上で実行する（WSL2 ではない）。
#   WSL2 側のセットアップは `make linux` を使用する。
# ==========================================================

$ErrorActionPreference = "Stop"

Write-Host "Bootstrap for Windows (winget)"

# winget の存在確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget が見つかりません。" -ForegroundColor Red
    Write-Host "  Microsoft Store から 'App Installer' をインストールしてください。"
    Write-Host "  参考: https://learn.microsoft.com/windows/package-manager/winget/"
    exit 1
}

# Wingetfile のパス（このスクリプトの1つ上の階層）
$wingetfile = Join-Path $PSScriptRoot "..\Wingetfile"

if (-not (Test-Path $wingetfile)) {
    Write-Host "Wingetfile が見つかりません: $wingetfile" -ForegroundColor Red
    exit 1
}

Write-Host "Installing Windows apps via winget..."

# コメント行・空行を除き、ID（最初のトークン）を取り出してインストール
Get-Content $wingetfile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }

    $pkg = ($line -split '\s+')[0]
    Write-Host "winget install: $pkg"

    # winget は exe のため失敗しても例外を投げない。終了コードで結果を確認する
    winget install --id $pkg -e --source winget `
        --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  $pkg のインストールに失敗（既にインストール済み / ID 不一致の可能性）" -ForegroundColor Yellow
    }
}

# ------------------------
# Nerd Font のインストール（Fira Code Nerd Font）
# winget のパッケージには FiraCode Nerd Font が存在しないため、
# mac/Linux（scripts/defaults.sh）と同じ nerd-fonts のリリースから直接ダウンロードする
# ------------------------
function Install-NerdFont {
    $fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $alreadyInstalled = Test-Path $fontsFolder -PathType Container
    if ($alreadyInstalled) {
        $alreadyInstalled = (Get-ChildItem $fontsFolder -Filter "FiraCodeNerdFont*" -ErrorAction SilentlyContinue).Count -gt 0
    }

    if ($alreadyInstalled) {
        Write-Host "✅ Fira Code Nerd Font already installed" -ForegroundColor Green
        return
    }

    Write-Host "🔤 Installing Fira Code Nerd Font..."

    $zipPath = Join-Path $env:TEMP "FiraCode.zip"
    $extractPath = Join-Path $env:TEMP "FiraCodeNerdFont"

    try {
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        New-Item -ItemType Directory -Force -Path $fontsFolder | Out-Null

        Get-ChildItem -Path $extractPath -Filter "*.ttf" | ForEach-Object {
            Copy-Item $_.FullName -Destination $fontsFolder -Force
            New-ItemProperty -Force `
                -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" `
                -Name "$($_.BaseName) (TrueType)" `
                -PropertyType String `
                -Value $_.Name | Out-Null
        }

        Write-Host "✅ Fira Code Nerd Font installed" -ForegroundColor Green
    }
    catch {
        Write-Host "  Fira Code Nerd Font のインストールに失敗しました: $_" -ForegroundColor Yellow
    }
    finally {
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Install-NerdFont

Write-Host "Done." -ForegroundColor Green
