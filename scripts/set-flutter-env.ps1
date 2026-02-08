# Chỉ set biến môi trường cho Flutter (khi đã có thư mục flutter sẵn)
# Cách dùng: .\set-flutter-env.ps1 -FlutterPath "C:\src\flutter"
# Hoặc chỉnh $FlutterRoot bên dưới rồi chạy script

param(
    [string]$FlutterPath = "C:\src\flutter"
)

if (-not (Test-Path $FlutterPath)) {
    Write-Host "Folder not found: $FlutterPath" -ForegroundColor Red
    Write-Host "Install Flutter first, or pass -FlutterPath 'D:\path\to\flutter'" -ForegroundColor Yellow
    exit 1
}

$FlutterBin = Join-Path $FlutterPath "bin"
if (-not (Test-Path (Join-Path $FlutterBin "flutter.bat"))) {
    Write-Host "Invalid Flutter path (flutter.bat not found in $FlutterBin)" -ForegroundColor Red
    exit 1
}

# Set User environment variables (persistent)
[Environment]::SetEnvironmentVariable("FLUTTER_ROOT", $FlutterPath, "User")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$FlutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$FlutterBin", "User")
    Write-Host "Added to PATH: $FlutterBin" -ForegroundColor Green
}
Write-Host "FLUTTER_ROOT = $FlutterPath" -ForegroundColor Green
Write-Host "Restart terminal/IDE for PATH to apply. Then run: flutter doctor" -ForegroundColor Yellow
