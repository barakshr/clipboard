# Build Instructions for Clipboard Manager

This guide will help you build and run the Clipboard Manager app on your macOS system.

## Prerequisites

- macOS 12.0 (Monterey) or later
- Xcode 15.0 or later
- Xcode Command Line Tools installed

## Building the App

### Option 1: Build and Run in Xcode (Recommended)

This is the easiest way to build and test the app.

1. **Open the Project**
   ```bash
   cd /tmp/clipboard-manager
   open ClipboardManager.xcodeproj
   ```

2. **Wait for Dependencies**
   - Xcode will automatically download the SQLite.swift package
   - This may take a minute on first open

3. **Select Build Target**
   - Ensure "ClipboardManager" is selected in the scheme dropdown
   - Ensure "My Mac" is selected as the destination

4. **Build and Run**
   - Press `Cmd + R` or click the Play button
   - The app should build and launch
   - Look for the clipboard icon in your menu bar

### Option 2: Build from Command Line

If you prefer command-line building:

1. **Navigate to Project Directory**
   ```bash
   cd /tmp/clipboard-manager
   ```

2. **Build the Project**
   ```bash
   xcodebuild -project ClipboardManager.xcodeproj \
              -scheme ClipboardManager \
              -configuration Release \
              -derivedDataPath ./build
   ```

3. **Find the Built App**
   ```bash
   # The app will be located at:
   ./build/Build/Products/Release/ClipboardManager.app
   ```

4. **Run the App**
   ```bash
   open ./build/Build/Products/Release/ClipboardManager.app
   ```

### Option 3: Swift Package Manager (Alternative)

The project includes a Package.swift file for SPM compatibility:

```bash
cd /tmp/clipboard-manager
swift build -c release
```

However, note that SPM builds may not include all macOS app bundle resources. Xcode is recommended.

## Post-Build Setup

### 1. Grant Accessibility Permissions

On first launch, you'll be prompted to grant Accessibility permissions:

1. Click "Open System Preferences" when prompted
2. Navigate to: **System Preferences > Security & Privacy > Privacy > Accessibility**
3. Click the lock icon (bottom-left) and authenticate
4. Find "ClipboardManager" in the list and check the box
5. If the app isn't listed, click the "+" button and navigate to the app
6. Restart the app after granting permissions

### 2. Test the Keyboard Shortcut

- Copy some text to your clipboard
- Press `Ctrl + \`` (Control + Backtick)
- The Clipboard Manager popup should appear

### 3. Configure Launch at Login (Optional)

1. Click the menu bar icon
2. Select "Settings..."
3. Check "Launch at Login"

## Troubleshooting Build Issues

### Issue: "SQLite.swift" Package Not Found

**Solution:**
1. In Xcode, go to **File > Packages > Reset Package Caches**
2. Then **File > Packages > Update to Latest Package Versions**
3. Clean and rebuild (Cmd + Shift + K, then Cmd + B)

### Issue: Code Signing Errors

**Solution:**
1. In Xcode, select the project in the navigator
2. Select the "ClipboardManager" target
3. Go to "Signing & Capabilities"
4. Ensure "Automatically manage signing" is checked
5. Select your development team or use "Sign to Run Locally"

### Issue: Build Fails with "Command PhaseScriptExecution failed"

**Solution:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean project
cd /tmp/clipboard-manager
xcodebuild clean

# Rebuild
open ClipboardManager.xcodeproj
```

### Issue: "The app can't be opened because Apple cannot check it for malicious software"

**Solution:**
```bash
# Remove quarantine attribute
xattr -cr /path/to/ClipboardManager.app

# Or right-click the app, select "Open" and confirm
```

## Creating a Distributable Build

To create a version you can share with others:

### 1. Archive the App

1. In Xcode, select **Product > Archive**
2. Wait for the archive to complete
3. The Organizer window will open

### 2. Export the App

1. Select your archive in the Organizer
2. Click "Distribute App"
3. Choose distribution method:
   - **Development**: For personal use on your own machines
   - **Developer ID**: For distribution outside the App Store (requires paid Developer Program)
   - **Copy App**: For local distribution (not recommended)

### 3. Notarize (Optional, for public distribution)

If distributing to other users:

```bash
# Submit for notarization (requires Developer ID)
xcrun notarytool submit ClipboardManager.app.zip \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "TEAM_ID"

# Staple the notarization
xcrun stapler staple ClipboardManager.app
```

## Installing the App

### For Development/Testing

The app runs directly from where it's built. You can:

1. Run it from Xcode (stays running while Xcode is open)
2. Copy it to your Applications folder:
   ```bash
   cp -r ./build/Build/Products/Release/ClipboardManager.app /Applications/
   ```

### For Permanent Installation

1. Build a Release version (Option 2 above)
2. Copy to Applications:
   ```bash
   cp -r ./build/Build/Products/Release/ClipboardManager.app /Applications/
   ```
3. Launch from Applications folder
4. Configure to launch at login via Settings

## Uninstalling

To completely remove the app:

```bash
# Remove the application
rm -rf /Applications/ClipboardManager.app

# Remove stored data
rm -rf ~/Library/Application\ Support/ClipboardManager

# Remove preferences
defaults delete com.clipboardmanager.app

# Remove from login items (if configured)
# Go to: System Preferences > Users & Groups > Login Items
```

## Development Tips

### Running in Debug Mode

Debug builds include additional logging. Check Console.app and filter for "ClipboardManager" to see debug output.

### Modifying the Code

Key files to modify for customization:

- **Keyboard Shortcut**: `ShortcutManager.swift` - Change default shortcut
- **Storage Limit**: `ClipboardStorage.swift` - Change `maxItems` property
- **Polling Interval**: `ClipboardMonitor.swift` - Change timer interval
- **UI Appearance**: `PopupWindowController.swift` - Modify window size/style

### Debugging Tips

1. **Enable Zombie Objects**: In Xcode scheme, enable Zombie Objects to catch memory issues
2. **Breakpoints**: Set breakpoints in key methods:
   - `ClipboardMonitor.checkClipboard()` - clipboard detection
   - `ShortcutManager.onShortcutPressed` - shortcut handling
   - `ClipboardStorage.saveItem()` - database operations
3. **Console Logging**: Check `print()` statements in Console.app

## Building for Different macOS Versions

### For macOS 12 (Monterey)

The default configuration supports macOS 12+. No changes needed.

### For macOS 13+ Only

If you want to use newer APIs available only in macOS 13+:

1. Open project settings in Xcode
2. Change "Deployment Target" to 13.0
3. Update `MACOSX_DEPLOYMENT_TARGET` in project.pbxproj
4. Use `#available(macOS 13.0, *)` checks for version-specific code

## Performance Optimization

For release builds, ensure these optimizations are enabled:

1. **Optimization Level**: `-O` (whole module optimization)
2. **Strip Debug Symbols**: Enabled
3. **Dead Code Stripping**: Enabled

These are already configured in the Release build configuration.

## Getting Help

If you encounter build issues not covered here:

1. Check Console.app for error messages
2. Clean derived data and rebuild
3. Ensure Xcode and macOS are up to date
4. Verify all system requirements are met

---

**Questions or Issues?** Review the main README.md for app usage and troubleshooting.

