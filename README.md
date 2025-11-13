# Clipboard Manager for macOS

A native macOS clipboard manager that runs in your menu bar, providing quick access to your clipboard history via a configurable keyboard shortcut.

## Features

- 📋 **Clipboard History**: Stores last 100 clipboard items (text and images)
- 🔍 **Smart Search**: Search through your clipboard history with prefix matching
- ⭐ **Favorites**: Mark important items as favorites to prevent deletion
- ⌨️ **Keyboard Shortcut**: Quick access via customizable global shortcut (default: Ctrl + `)
- 💾 **Persistent Storage**: History persists between app restarts
- 🎯 **Menu Bar App**: Runs silently in the background
- 🚀 **Launch at Login**: Optional auto-start on system boot
- 🌓 **Dark Mode**: Full support for macOS dark mode

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 15.0 or later (for building)
- Accessibility permissions (for global keyboard shortcuts)

## Installation

### Option 1: Build from Source

1. Clone or download this repository
2. Open `ClipboardManager.xcodeproj` in Xcode
3. Build and run the project (Cmd + R)
4. The app will appear in your menu bar

### Option 2: Using Swift Package Manager

```bash
cd /tmp/clipboard-manager
swift build -c release
```

The compiled app will be in `.build/release/`

## First Run Setup

On first launch, the app will request **Accessibility permissions**. This is required for the global keyboard shortcut to work.

1. When prompted, click "Open System Preferences"
2. Navigate to: **System Preferences > Security & Privacy > Privacy > Accessibility**
3. Click the lock icon and authenticate
4. Check the box next to "ClipboardManager"
5. Restart the app if necessary

## Usage

### Opening the Clipboard Manager

- **Keyboard Shortcut**: Press `Ctrl + \`` (Control + Backtick) - configurable in settings
- **Menu Bar**: Click the clipboard icon in the menu bar and select "Open Clipboard Manager"

### Managing Clipboard Items

- **View Recent Items**: The popup shows your last 10 clipboard items by default
- **Search**: Type in the search field to find older items (prefix search)
- **Copy Item**: Double-click any item or select it and press Enter
- **Mark as Favorite**: Click the star icon next to any item
- **Auto-Close**: The window automatically closes when you click outside it

### Settings

Access settings from the menu bar icon:

- **Change Keyboard Shortcut**: Click "Change Shortcut" and press your desired key combination
- **Launch at Login**: Enable to start the app automatically when you log in
- **Clear History**: Remove all non-favorite items from your clipboard history

## How It Works

### Clipboard Monitoring

The app monitors your system clipboard every 0.5 seconds and automatically saves:
- Plain text
- Images (PNG format)

### Storage

- **Maximum Items**: 100 (non-favorite items are removed when limit is reached)
- **Favorites**: Never deleted automatically
- **Database**: Uses SQLite for efficient storage
- **Location**: `~/Library/Application Support/ClipboardManager/clipboard.sqlite3`

### Search

Search uses **prefix matching**, meaning it searches from the beginning of clipboard text content. For example:
- Searching "hello" will find "hello world" ✅
- Searching "world" will NOT find "hello world" ❌

## Keyboard Shortcuts

### In Popup Window

- `Ctrl + \``: Toggle window (configurable)
- `Esc`: Close window
- `↑/↓`: Navigate items
- `Enter`: Copy selected item
- `Cmd + F`: Focus search field

### Customizing the Shortcut

1. Open Settings from menu bar
2. Click "Change Shortcut"
3. Press your desired key combination (e.g., Cmd + Shift + V)
4. The shortcut is saved automatically

## Troubleshooting

### Global Shortcut Not Working

1. Check that Accessibility permissions are granted:
   - System Preferences > Security & Privacy > Privacy > Accessibility
   - Ensure ClipboardManager is checked
2. Try restarting the app
3. Check if another app is using the same shortcut

### App Not Appearing in Menu Bar

- Make sure the app is running (check Activity Monitor)
- Try restarting your Mac
- Rebuild the app in Xcode

### Clipboard Items Not Saving

- Check permissions for `~/Library/Application Support/ClipboardManager/`
- Ensure the app has necessary file system access
- Check Console.app for error messages

### Launch at Login Not Working

- For macOS 13+: This feature uses the ServiceManagement framework
- For macOS 12: Manually add the app to System Preferences > Users & Groups > Login Items

## Privacy

Clipboard Manager stores all data locally on your Mac. No data is sent to any external servers or third parties.

**Data Location**: `~/Library/Application Support/ClipboardManager/`

## Technical Details

### Architecture

- **Language**: Swift 5.9+
- **Framework**: AppKit (native macOS)
- **Database**: SQLite 3 (via SQLite.swift)
- **Keyboard Shortcuts**: Carbon Event Manager

### Project Structure

```
ClipboardManager/
├── ClipboardManagerApp.swift      # App entry point & delegate
├── Models/
│   ├── ClipboardItem.swift        # Data model for clipboard items
│   └── ClipboardStorage.swift     # SQLite database manager
├── Core/
│   ├── ClipboardMonitor.swift     # Monitors system clipboard
│   └── ShortcutManager.swift      # Global keyboard shortcut handler
├── UI/
│   ├── PopupWindowController.swift    # Main popup window
│   └── SettingsWindowController.swift # Settings window
└── Info.plist                     # App configuration
```

### Key Components

1. **ClipboardMonitor**: Polls `NSPasteboard` for changes
2. **ClipboardStorage**: Manages SQLite database with CRUD operations
3. **ShortcutManager**: Registers global keyboard shortcuts using Carbon API
4. **PopupWindowController**: Manages the floating popup window with search and list

## Building for Distribution

To create a distributable app:

1. Open the project in Xcode
2. Select "Product > Archive"
3. Export the app with your Developer ID or for local distribution
4. Notarize the app (required for macOS 10.15+) if distributing publicly

## Known Limitations

- Clipboard monitoring polls every 0.5 seconds (not event-driven)
- Image support limited to formats supported by NSImage
- Rich text is stored as plain text
- No cloud sync between devices
- Launch at Login requires macOS 13+ for automatic setup

## Future Enhancements

Potential features for future versions:
- iCloud sync across devices
- Rich text format preservation
- File path support
- Snippets and templates
- Quick paste with numbered shortcuts
- Custom categories/tags
- Export/import clipboard history

## License

This project is provided as-is for personal use. Feel free to modify and distribute as needed.

## Credits

Built with:
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) - A type-safe Swift interface to SQLite3

## Support

If you encounter issues:
1. Check the Troubleshooting section above
2. Review Console.app for error messages
3. Ensure you're running a compatible macOS version
4. Verify all required permissions are granted

---

**Version**: 1.0  
**Minimum macOS**: 12.0 (Monterey)  
**Last Updated**: November 2025

