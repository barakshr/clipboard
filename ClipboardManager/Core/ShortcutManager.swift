import Cocoa
import Carbon

class ShortcutManager {
    var onShortcutPressed: (() -> Void)?
    private var hotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    
    private var currentKeyCode: UInt32 = UInt32(kVK_ANSI_Grave) // backtick
    private var currentModifiers: UInt32 = UInt32(controlKey) // Control
    
    func registerShortcut() {
        // Load saved shortcut from UserDefaults
        loadShortcutConfiguration()
        
        // Register the shortcut
        var hotKeyID = EventHotKeyID(signature: OSType(0x4D495441), id: 1)
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            let manager = Unmanaged<ShortcutManager>.fromOpaque(userData!).takeUnretainedValue()
            manager.onShortcutPressed?()
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        RegisterEventHotKey(currentKeyCode, currentModifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKey)
    }
    
    func unregisterShortcut() {
        if let hotKey = hotKey {
            UnregisterEventHotKey(hotKey)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
    
    func updateShortcut(keyCode: UInt32, modifiers: UInt32) {
        // Unregister old shortcut
        unregisterShortcut()
        
        // Update values
        currentKeyCode = keyCode
        currentModifiers = modifiers
        
        // Save to UserDefaults
        saveShortcutConfiguration()
        
        // Register new shortcut
        registerShortcut()
    }
    
    private func saveShortcutConfiguration() {
        UserDefaults.standard.set(currentKeyCode, forKey: "shortcutKeyCode")
        UserDefaults.standard.set(currentModifiers, forKey: "shortcutModifiers")
    }
    
    private func loadShortcutConfiguration() {
        if UserDefaults.standard.object(forKey: "shortcutKeyCode") != nil {
            currentKeyCode = UInt32(UserDefaults.standard.integer(forKey: "shortcutKeyCode"))
            currentModifiers = UInt32(UserDefaults.standard.integer(forKey: "shortcutModifiers"))
        }
    }
    
    func getCurrentShortcutDescription() -> String {
        var modifierString = ""
        
        if currentModifiers & UInt32(controlKey) != 0 {
            modifierString += "⌃"
        }
        if currentModifiers & UInt32(optionKey) != 0 {
            modifierString += "⌥"
        }
        if currentModifiers & UInt32(shiftKey) != 0 {
            modifierString += "⇧"
        }
        if currentModifiers & UInt32(cmdKey) != 0 {
            modifierString += "⌘"
        }
        
        let keyString = keyCodeToString(currentKeyCode)
        return modifierString + keyString
    }
    
    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch keyCode {
        case UInt32(kVK_ANSI_Grave): return "`"
        case UInt32(kVK_ANSI_A): return "A"
        case UInt32(kVK_ANSI_B): return "B"
        case UInt32(kVK_ANSI_C): return "C"
        case UInt32(kVK_ANSI_D): return "D"
        case UInt32(kVK_ANSI_E): return "E"
        case UInt32(kVK_ANSI_F): return "F"
        case UInt32(kVK_ANSI_G): return "G"
        case UInt32(kVK_ANSI_H): return "H"
        case UInt32(kVK_ANSI_I): return "I"
        case UInt32(kVK_ANSI_J): return "J"
        case UInt32(kVK_ANSI_K): return "K"
        case UInt32(kVK_ANSI_L): return "L"
        case UInt32(kVK_ANSI_M): return "M"
        case UInt32(kVK_ANSI_N): return "N"
        case UInt32(kVK_ANSI_O): return "O"
        case UInt32(kVK_ANSI_P): return "P"
        case UInt32(kVK_ANSI_Q): return "Q"
        case UInt32(kVK_ANSI_R): return "R"
        case UInt32(kVK_ANSI_S): return "S"
        case UInt32(kVK_ANSI_T): return "T"
        case UInt32(kVK_ANSI_U): return "U"
        case UInt32(kVK_ANSI_V): return "V"
        case UInt32(kVK_ANSI_W): return "W"
        case UInt32(kVK_ANSI_X): return "X"
        case UInt32(kVK_ANSI_Y): return "Y"
        case UInt32(kVK_ANSI_Z): return "Z"
        case UInt32(kVK_Space): return "Space"
        case UInt32(kVK_Return): return "↩"
        default: return "?"
        }
    }
}

