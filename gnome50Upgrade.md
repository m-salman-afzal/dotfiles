# GNOME 50 Extension Upgrade Notes

## Overview
After upgrading to GNOME 50 (Ubuntu 25.04), several extensions broke due to version incompatibility and API changes. This document tracks all changes made to fix them.

## Settings Change
- Enabled `disable-extension-version-validation` in gsettings as a safety net:
  ```
  gsettings set org.gnome.shell disable-extension-version-validation true
  ```

## Version Bumps
Added `"50"` to the `shell-version` array in `metadata.json` for:

| Extension | Directory |
|-----------|-----------|
| Dash to Panel | `dash-to-panel@jderose9.github.com` |
| Color Picker | `color-picker@tuberry` |
| Notification Timeout | `notification-timeout@chlumskyvaclav.gmail.com` |
| Smart Auto Move | `smart-auto-move@khimaros.com` |
| Touchpad Gesture Customization | `touchpad-gesture-customization@coooolapps.com` |

## API Fixes

### `affectsInputRegion` parameter removed in GNOME 50
In GNOME 50, `Main.layoutManager.addChrome()` and `trackChrome()` only accept `{ trackFullscreen, affectsStruts }`. The `affectsInputRegion` parameter was removed from `defaultParams` in `layout.js`, and `Params.parse()` throws on unrecognized keys.

#### dash-to-panel@jderose9.github.com/panelManager.js
- **Line 673**: Removed `{ affectsInputRegion: false }` from `addChrome(clipContainer, ...)` call
- **Lines 690-693**: Removed `affectsInputRegion: true` from `trackChrome(panel, ...)` call (kept `affectsStruts: false`)

#### dash-to-panel@jderose9.github.com/windowPreview.js
- **Line 113**: Removed `{ affectsInputRegion: false }` from `addChrome(this, ...)` call
- **Line 114**: Removed `{ affectsInputRegion: true }` from `trackChrome(this.menu, ...)` call

#### just-perfection-desktop@just-perfection/lib/API.js
- **Line 1071**: Removed `affectsInputRegion: true` from `addChrome(element, ...)` call (kept `affectsStruts` and `trackFullscreen`)

### `ignoreRelease()` removed from PopupMenuManager in GNOME 50
The `PopupMenuManager.ignoreRelease()` method no longer exists in GNOME 50's `popupMenu.js`.

#### dash-to-panel@jderose9.github.com/appIcons.js
- **Line 914**: Wrapped `this._menuManager.ignoreRelease()` in an existence check
- **Line 2226**: Same fix applied

### `.overview-tile` CSS padding causing icon misalignment on hover
In GNOME 50, `AppIcon` uses the `overview-tile` style class (designed for the app grid). Themes like Orchis-Dark add `padding: 12px; border-radius: 30px;` to this class, which shifts icons off-center in the panel taskbar. Dash-to-panel's stylesheet only reset `background` but not padding/border.

#### dash-to-panel@jderose9.github.com/stylesheet.css
- Added `padding: 0; border: none; border-radius: 0;` to the `#dashtopanelScrollview .overview-tile, .dashtopanelMainPanel .overview-tile` rule

## Tray Icons (Slack, Discord, etc.)
Dash-to-panel does **not** provide tray icon hosting — it only styles/arranges tray icons in the panel. The actual tray icon support requires the **AppIndicator** extension. On Wayland, there is no legacy X11 tray; apps use the StatusNotifierItem (SNI) D-Bus protocol, which AppIndicator handles.

## Backups
Original unmodified copies saved with `.bak` suffix in `~/.local/share/gnome-shell/extensions/`:
- `dash-to-panel@jderose9.github.com.bak`
- `color-picker@tuberry.bak`
- `notification-timeout@chlumskyvaclav.gmail.com.bak`
- `smart-auto-move@khimaros.com.bak`
- `touchpad-gesture-customization@coooolapps.com.bak`
- `just-perfection-desktop@just-perfection.bak`

## Newly Installed Extensions

### AppIndicator and KStatusNotifierItem Support (`appindicatorsupport@rgcjonas.gmail.com`)
- **Problem**: Tray icons for apps like Slack were not appearing. GNOME removed the built-in system tray; an extension is required.
- **Solution**: Installed v63 from [ubuntu/gnome-shell-extension-appindicator](https://github.com/ubuntu/gnome-shell-extension-appindicator) GitHub releases. This version natively supports GNOME 50.
- **Install method**: Downloaded zip, extracted to `~/.local/share/gnome-shell/extensions/appindicatorsupport@rgcjonas.gmail.com/`
- **Pre-configured**: Added to `enabled-extensions` in gsettings. Enabled and ACTIVE.

## Broken/Empty Extensions (not fixable)
These extensions are symlinks pointing to empty directories in `~/dotfiles/.local/share/gnome-shell/extensions/`:
- `Vitals@CoreCoding.com`
- `blur-my-shell@auber.vitale`
- `auto-move-windows@gnome-shell-extensions.gcampax.github.com`

These need to be reinstalled from extensions.gnome.org or their repos.

## Status After Changes

| Extension | Status |
|-----------|--------|
| Color Picker | Working |
| Smart Auto Move | Working |
| Notification Timeout | Working |
| Just Perfection | Working (needs re-login to verify) |
| Dash to Panel | Working (ignoreRelease fix needs re-login) |
| Touchpad Gesture Customization | Needs re-login to verify |
| AppIndicator (tray icons) | Working - provides Slack/Discord etc. tray icons |

**Note:** GNOME Shell on Wayland caches JS in memory. A session logout/login is required for JS code changes to take effect.
