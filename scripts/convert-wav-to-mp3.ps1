$soundsDir = "d:/Sources/cryptocurrency-trading-app/fe-cryptocurrency-trading-app/assets/sounds"
Set-Location $soundsDir

Get-ChildItem -Filter "*.wav" | ForEach-Object {
    $mp3Name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + ".mp3"
    Write-Host "Converting $($_.Name) -> $mp3Name"
    ffmpeg -y -i $_.FullName -b:a 128k -ar 44100 $mp3Name 2>&1 | Select-Object -Last 3
}

Write-Host ""
Write-Host "Done! Listing MP3 files:"
Get-ChildItem -Filter "*.mp3"
