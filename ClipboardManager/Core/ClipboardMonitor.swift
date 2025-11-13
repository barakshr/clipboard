import Cocoa
import Foundation

class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    
    func startMonitoring() {
        lastChangeCount = pasteboard.changeCount
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        lastChangeCount = pasteboard.changeCount
        
        // Check for text content
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            let item = ClipboardItem(
                contentType: .text,
                textContent: text
            )
            saveIfNotDuplicate(item)
            return
        }
        
        // Check for image content
        if let image = NSImage(pasteboard: pasteboard),
           let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            let item = ClipboardItem(
                contentType: .image,
                imageData: pngData
            )
            saveIfNotDuplicate(item)
            return
        }
    }
    
    private func saveIfNotDuplicate(_ item: ClipboardItem) {
        if !ClipboardStorage.shared.isDuplicate(item) {
            ClipboardStorage.shared.saveItem(item)
        }
    }
}

