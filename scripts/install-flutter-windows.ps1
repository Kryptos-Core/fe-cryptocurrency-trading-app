# Script cài Flutter trên Windows và set biến môi trường
# Chạy PowerShell "Run as Administrator" nếu clone vào C:\
# Hoặc chạy bình thường để cài vào thư mục user

$ErrorActionPreference = "Stop"
$FlutterRoot = "C:\src\flutter"
$FlutterBin = "$FlutterRoot\bin"

# Nếu không có quyền ghi C:\, dùng thư mục user
if (-not (Test-Path "C:\src") -and -not (Test-Path "C:\")) {
    $FlutterRoot = "$env:USERPROFILE\flutter"
    $FlutterBin = "$FlutterRoot\bin"
}

Write-Host "Flutter will be installed to: $FlutterRoot" -ForegroundColor Cyan

# 1. Tạo thư mục và clone Flutter (stable)
$parent = Split-Path $FlutterRoot -Parent
if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
}

if (Test-Path $FlutterRoot) {
    Write-Host "Flutter folder already exists. Updating..." -ForegroundColor Yellow
    Set-Location $FlutterRoot
    git pull
    git checkout stable
} else {
    Write-Host "Cloning Flutter (stable channel)..." -ForegroundColor Green
    git clone https://github.com/flutter/flutter.git -b stable $FlutterRoot
}

# 2. Set biến môi trường (User - không cần Admin)
[Environment]::SetEnvironmentVariable("FLUTTER_ROOT", $FlutterRoot, "User")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$FlutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$FlutterBin", "User")
    Write-Host "Added $FlutterBin to PATH (User)" -ForegroundColor Green
} else {
    Write-Host "PATH already contains Flutter bin" -ForegroundColor Gray
}
Write-Host "Set FLUTTER_ROOT = $FlutterRoot" -ForegroundColor Green

# 3. Cập nhật PATH cho session hiện tại
$env:FLUTTER_ROOT = $FlutterRoot
$env:Path = "$env:Path;$FlutterBin"

# 4. Chạy flutter lần đầu để tải Dart SDK và kiểm tra
Write-Host "`nRunning 'flutter --version' (first run may download Dart SDK)..." -ForegroundColor Cyan
& "$FlutterBin\flutter.bat" --version

Write-Host "`nDone. Run 'flutter doctor' to check dependencies." -ForegroundColor Green
Write-Host "You may need to RESTART terminal/IDE for PATH to take effect." -ForegroundColor Yellow
