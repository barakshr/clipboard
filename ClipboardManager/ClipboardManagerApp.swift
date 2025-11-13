import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
    
    var statusItem: NSStatusItem!
    var clipboardMonitor: ClipboardMonitor!
    var shortcutManager: ShortcutManager!
    var popupWindowController: PopupWindowController!
    var settingsWindowController: SettingsWindowController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("🚀 App starting...")
        
        // Initialize storage
        NSLog("📦 Initializing storage...")
        ClipboardStorage.shared.initialize()
        NSLog("✅ Storage initialized")
        
        // Create status bar item
        NSLog("📍 Setting up status bar...")
        setupStatusBar()
        NSLog("✅ Status bar setup complete")
        
        // Initialize clipboard monitor
        NSLog("👀 Starting clipboard monitor...")
        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor.startMonitoring()
        NSLog("✅ Clipboard monitor started")
        
        // Initialize keyboard shortcut
        NSLog("⌨️  Registering keyboard shortcut...")
        shortcutManager = ShortcutManager()
        shortcutManager.onShortcutPressed = { [weak self] in
            self?.togglePopup()
        }
        shortcutManager.registerShortcut()
        NSLog("✅ Keyboard shortcut registered")
        
        // Create popup window controller
        NSLog("🪟 Creating popup window...")
        popupWindowController = PopupWindowController()
        NSLog("✅ Popup window created")
        
        // Create settings window controller
        NSLog("⚙️  Creating settings window...")
        settingsWindowController = SettingsWindowController()
        NSLog("✅ Settings window created")
        
        // Check for accessibility permissions
        NSLog("🔐 Checking accessibility permissions...")
        checkAccessibilityPermissions()
        
        NSLog("🎉 App fully initialized!")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stopMonitoring()
        shortcutManager.unregisterShortcut()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Try SF Symbol first, fallback to text
            if let image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager") {
                button.image = image
                NSLog("✅ Using SF Symbol for menu bar icon")
            } else {
                button.title = "📋"
                NSLog("⚠️ SF Symbol not available, using text icon")
            }
        } else {
            NSLog("❌ ERROR: Could not create status bar button!")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Clipboard Manager", action: #selector(openPopup), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
        NSLog("✅ Status bar menu configured with \(menu.items.count) items")
    }
    
    @objc private func openPopup() {
        popupWindowController.showWindow(nil)
    }
    
    @objc private func togglePopup() {
        if popupWindowController.window?.isVisible == true {
            popupWindowController.close()
        } else {
            popupWindowController.showWindow(nil)
        }
    }
    
    @objc private func openSettings() {
        settingsWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessibilityEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showPermissionAlert()
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "ClipboardManager needs accessibility access to register global keyboard shortcuts. Please grant permission in System Preferences > Security & Privacy > Privacy > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
