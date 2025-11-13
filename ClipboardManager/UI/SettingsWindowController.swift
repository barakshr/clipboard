import Cocoa
import ServiceManagement
import Carbon

class SettingsWindowController: NSWindowController {
    private var settingsViewController: SettingsViewController!
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Settings"
        window.isReleasedWhenClosed = false
        
        self.init(window: window)
        
        settingsViewController = SettingsViewController()
        window.contentViewController = settingsViewController
        window.center()
    }
}

class SettingsViewController: NSViewController {
    private var shortcutLabel: NSTextField!
    private var shortcutButton: NSButton!
    private var launchAtLoginCheckbox: NSButton!
    private var clearHistoryButton: NSButton!
    private var recordingShortcut = false
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = NSTextField(labelWithString: "Clipboard Manager Settings")
        titleLabel.frame = NSRect(x: 20, y: view.bounds.height - 50, width: 460, height: 30)
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.alignment = .center
        view.addSubview(titleLabel)
        
        // Keyboard Shortcut Section
        let shortcutTitleLabel = NSTextField(labelWithString: "Keyboard Shortcut:")
        shortcutTitleLabel.frame = NSRect(x: 20, y: view.bounds.height - 100, width: 150, height: 20)
        shortcutTitleLabel.font = .boldSystemFont(ofSize: 13)
        view.addSubview(shortcutTitleLabel)
        
        shortcutLabel = NSTextField(labelWithString: getShortcutDescription())
        shortcutLabel.frame = NSRect(x: 180, y: view.bounds.height - 100, width: 200, height: 20)
        shortcutLabel.font = .systemFont(ofSize: 13)
        view.addSubview(shortcutLabel)
        
        shortcutButton = NSButton(title: "Change Shortcut", target: self, action: #selector(changeShortcut))
        shortcutButton.frame = NSRect(x: 180, y: view.bounds.height - 130, width: 150, height: 30)
        view.addSubview(shortcutButton)
        
        // Launch at Login
        launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch at Login", target: self, action: #selector(toggleLaunchAtLogin))
        launchAtLoginCheckbox.frame = NSRect(x: 20, y: view.bounds.height - 170, width: 200, height: 20)
        launchAtLoginCheckbox.state = getLaunchAtLoginStatus() ? .on : .off
        view.addSubview(launchAtLoginCheckbox)
        
        // Clear History
        let clearHistoryLabel = NSTextField(labelWithString: "Clear History:")
        clearHistoryLabel.frame = NSRect(x: 20, y: view.bounds.height - 220, width: 150, height: 20)
        clearHistoryLabel.font = .boldSystemFont(ofSize: 13)
        view.addSubview(clearHistoryLabel)
        
        clearHistoryButton = NSButton(title: "Clear All (Keep Favorites)", target: self, action: #selector(clearHistory))
        clearHistoryButton.frame = NSRect(x: 180, y: view.bounds.height - 220, width: 200, height: 30)
        view.addSubview(clearHistoryButton)
        
        // Info label
        let infoLabel = NSTextField(labelWithString: "Note: Accessibility permissions are required for global shortcuts.")
        infoLabel.frame = NSRect(x: 20, y: 20, width: 460, height: 40)
        infoLabel.font = .systemFont(ofSize: 11)
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.alignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        view.addSubview(infoLabel)
    }
    
    @objc private func changeShortcut() {
        if !recordingShortcut {
            recordingShortcut = true
            shortcutButton.title = "Press keys..."
            shortcutButton.isEnabled = false
            view.window?.makeFirstResponder(view)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if recordingShortcut {
            let keyCode = event.keyCode
            var modifiers: UInt32 = 0
            
            let flags = event.modifierFlags
            if flags.contains(.control) {
                modifiers |= UInt32(controlKey)
            }
            if flags.contains(.option) {
                modifiers |= UInt32(optionKey)
            }
            if flags.contains(.shift) {
                modifiers |= UInt32(shiftKey)
            }
            if flags.contains(.command) {
                modifiers |= UInt32(cmdKey)
            }
            
            // Update shortcut
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.shortcutManager.updateShortcut(keyCode: UInt32(keyCode), modifiers: modifiers)
                shortcutLabel.stringValue = appDelegate.shortcutManager.getCurrentShortcutDescription()
            }
            
            recordingShortcut = false
            shortcutButton.title = "Change Shortcut"
            shortcutButton.isEnabled = true
        } else {
            super.keyDown(with: event)
        }
    }
    
    @objc private func toggleLaunchAtLogin() {
        let enabled = launchAtLoginCheckbox.state == .on
        setLaunchAtLogin(enabled: enabled)
    }
    
    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History?"
        alert.informativeText = "This will delete all clipboard items except favorites. This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            ClipboardStorage.shared.clearHistory()
            
            let successAlert = NSAlert()
            successAlert.messageText = "History Cleared"
            successAlert.informativeText = "All non-favorite clipboard items have been deleted."
            successAlert.alertStyle = .informational
            successAlert.runModal()
        }
    }
    
    private func getShortcutDescription() -> String {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            return appDelegate.shortcutManager.getCurrentShortcutDescription()
        }
        return "⌃`"
    }
    
    private func getLaunchAtLoginStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: "launchAtLogin")
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "launchAtLogin")
        
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
                showLaunchAtLoginError(enabled: enabled)
            }
        } else {
            // For macOS 12 and earlier, we'd need to use LaunchAgents
            // This is a simplified version - full implementation would require more code
            showLaunchAtLoginLegacyMessage()
        }
    }
    
    private func showLaunchAtLoginError(enabled: Bool) {
        let alert = NSAlert()
        alert.messageText = "Launch at Login Error"
        alert.informativeText = "Could not \(enabled ? "enable" : "disable") launch at login. Please try again."
        alert.alertStyle = .warning
        alert.runModal()
    }
    
    private func showLaunchAtLoginLegacyMessage() {
        let alert = NSAlert()
        alert.messageText = "Launch at Login"
        alert.informativeText = "On macOS 12 and earlier, please manually add the app to System Preferences > Users & Groups > Login Items."
        alert.alertStyle = .informational
        alert.runModal()
    }
}

