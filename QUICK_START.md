# Quick Start Guide

Get up and running with Clipboard Manager in 5 minutes!

## Step 1: Open the Project (30 seconds)

```bash
cd /tmp/clipboard-manager
open ClipboardManager.xcodeproj



Xcode will open and automatically download dependencies (SQLite.swift).

## Step 2: Build and Run (1 minute)

In Xcode:
1. Wait for "Indexing..." to complete
2. Press `Cmd + R` (or  click the ▶️ Play button)
3. The app will build and launch

**Look for**: A clipboard icon in your menu bar (top-right of screen)

## Step 3: Grant Permissions (2 minutes)

A dialog will appear asking for Accessibility permissions:

1. Click **"Open System Preferences"**
2. Click the 🔒 lock icon and enter your password
3. Check the box next to **"ClipboardManager"**
4. Close System Preferences  

**Note**: If the app doesn't appear in the list, restart it and try again.

## Step 4: Test It Out! (1 minute)

1. **Copy some text**: Select any text and press `Cmd + C`
2. **Copy something else**: Copy different text a few times
3. **Open Clipboard Manager**: Press `Ctrl + \`` (Control + Backtick)
4. **See your history**: A popup shows your last 10 clipboard items!
5. **Reuse an item**: Double-click any item to copy it back to clipboard

## Step 5: Explore Features (1 minute)

### Mark as Favorite
Click the ⭐ star icon next to any clipboard item to save it permanently.

### Search Old Items
Type in the search box to find older clipboard items (searches from the beginning of text).

### Access Settings
Click the menu bar icon → "Settings..." to:
- Change keyboard shortcut
- Enable launch at login  
- Clear clipboard history

## You're Done! 🎉

The app is now running and monitoring your clipboard. It will:
- ✅ Automatically save your next 100 clipboard items
- ✅ Persist data between restarts
- ✅ Open instantly with `Ctrl + \``
- ✅ Run silently in your menu bar

## Common Shortcuts

- `Ctrl + \``: Open/close Clipboard Manager
- `Esc`: Close the popup
- `↑/↓`: Navigate clipboard items
- `Enter`: Copy selected item
- Double-click: Copy and close

## Next Steps

- Read `README.md` for full documentation
- Check `BUILD_INSTRUCTIONS.md` for advanced build options
- Customize the keyboard shortcut in Settings

## Troubleshooting

**Shortcut not working?**
→ Make sure Accessibility permissions are granted (Step 3)

**Nothing in history?**
→ Copy some text first! The app only saves clipboard changes after it starts.

**Menu bar icon missing?**
→ Check if the app is running. Restart it from Xcode.

---

Enjoy your new clipboard manager! 📋✨



