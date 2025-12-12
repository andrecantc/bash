#!/bin/bash
set -e

echo "==============================="
echo "  Installing Applications"
echo "==============================="

# --- Helpers ----------------------------------------------------------

install_pkg() {
    local url="$1"
    local name="$2"

    echo "📦 Installing PKG: $name"
    tmp=$(mktemp -d)
    pkgfile="$tmp/installer.pkg"

    curl -L "$url" -o "$pkgfile"
    sudo installer -pkg "$pkgfile" -target /
    rm -rf "$tmp"
}

install_dmg() {
    local url="$1"
    local name="$2"

    echo "🍎 Installing DMG: $name"
    tmp=$(mktemp -d)
    dmgfile="$tmp/app.dmg"

    curl -L "$url" -o "$dmgfile"

    mount_point=$(hdiutil attach "$dmgfile" -nobrowse -quiet | grep "/Volumes" | awk '{ $1=""; print substr($0,2) }')

    # Find first .app in mounted volume
    app_path=$(find "$mount_point" -maxdepth 1 -type d -name "*.app" | head -n 1)

    if [ -z "$app_path" ]; then
        echo "❌ ERROR: No .app found in DMG for $name"
        hdiutil detach "$mount_point" -quiet || true
        exit 1
    fi

    cp -R "$app_path" /Applications/

    hdiutil detach "$mount_point" -quiet
    rm -rf "$tmp"
}

# --- Installers --------------------------------------------------------

# 1. Cloudflare WARP (PKG)
install_pkg \
  "https://downloads.cloudflareclient.com/v1/download/macos/version/2025.9.558.0" \
  "Cloudflare WARP"

# 2. Microsoft Company Portal (PKG)
install_pkg \
  "https://officecdn.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/CompanyPortal-Installer.pkg" \
  "Microsoft Company Portal"

# 3. HiQ F5 VPN (PKG)
install_pkg \
  "https://access.hiq.se/public/download/mac_f5vpn.pkg" \
  "HiQ F5 VPN"

# 4. Microsoft Teams WebView2 Framework (PKG)
install_pkg \
  "https://statics.teams.cdn.office.net/production-osx/enterprise/webview2/lkg/MicrosoftTeams.pkg" \
  "Microsoft Teams WebView2"

# 5. Microsoft 365 Business Pro (PKG)
install_pkg \
  "https://officecdnmac.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_365_and_Office_16.102.25101223_BusinessPro_Installer.pkg" \
  "Microsoft 365 BusinessPro"

# 6. Citrix Workspace (DMG)
install_dmg \
  "https://downloads.citrix.com/25507/CitrixWorkspaceApp.dmg?__gda__=exp=1765551228~acl=/*~hmac=7c57ecc43916b9e63824313cfabfd2a642f84b87738deaaa4cfa9e012eae885a" \
  "Citrix Workspace"

# 7. NinjaOne ncplayer (DMG)
install_dmg \
  "https://resources.ninjarmm.com/development/ninjacontrol/11.35.7720/ncplayer.dmg" \
  "NinjaOne ncplayer"

echo ""
echo "🎉 All apps installed successfully!"

