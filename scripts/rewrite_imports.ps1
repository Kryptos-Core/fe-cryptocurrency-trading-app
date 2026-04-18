<#
.SYNOPSIS
  Bulk-rewrite package: imports after lib/ folder moves (Clean Architecture migration).

.USAGE
  .\scripts\rewrite_imports.ps1 -Root "lib","test"

  Edit $Replacements hashtable below when adding new path mappings.
#>
param(
  [string[]]$Root = @("lib", "test")
)

$Replacements = [ordered]@{
  # PR1 scaffolding
  "package:crypto_trading_app/core/di/injection_container.dart" = "package:crypto_trading_app/app/di/injection_container.dart"
  "package:crypto_trading_app/core/providers/locale_provider.dart" = "package:crypto_trading_app/core/localization/locale_provider.dart"
  "package:crypto_trading_app/core/providers/theme_provider.dart" = "package:crypto_trading_app/core/theme/theme_provider.dart"
  "package:crypto_trading_app/core/ui/app_responsive.dart" = "package:crypto_trading_app/core/responsive/app_responsive.dart"
  "package:crypto_trading_app/core/ui/app_scroll_behavior.dart" = "package:crypto_trading_app/core/responsive/app_scroll_behavior.dart"
  "package:crypto_trading_app/gen_l10n/" = "package:crypto_trading_app/core/gen_l10n/"
}

Write-Host "For bulk data/domain path migration see also: scripts/apply_import_rewrites.ps1"

foreach ($dir in $Root) {
  if (-not (Test-Path $dir)) { continue }
  Get-ChildItem -Path $dir -Recurse -Filter "*.dart" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_.FullName
    $c = Get-Content -Path $path -Raw -Encoding UTF8
    $n = $c
    foreach ($key in $Replacements.Keys) {
      $n = $n.Replace($key, $Replacements[$key])
    }
    if ($n -ne $c) {
      Set-Content -Path $path -Value $n -Encoding UTF8 -NoNewline
      Write-Host "updated: $path"
    }
  }
}
