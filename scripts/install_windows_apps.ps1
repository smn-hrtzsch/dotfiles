# scripts/install_windows_apps.ps1
# Run this in PowerShell as Administrator to install GUI apps on Windows

Write-Host ">>> Installing Windows Apps via winget..."

# List of apps to install (matching your Brewfile as close as possible)
$apps = @(
    "Brave.Brave",
    "Microsoft.VisualStudioCode",
    "Google.AndroidStudio",
    "Mozilla.Thunderbird",
    "WhatsApp.WhatsApp",
    "Zoom.Zoom",
    "Notion.Notion",
    "Spotify.Spotify",
    "Google.Drive",
    "Raycast.Raycast", # Note: Raycast is coming to Windows, ID might change or not be available yet!
    "Microsoft.DotNet.SDK.8",
    "Microsoft.PowerToys" # Alternative to some Mac utilities
)

foreach ($app in $apps) {
    Write-Host "   Installing $app..."
    winget install --id $app -e --source winget
}

Write-Host ">>> Windows Apps installation finished!"
