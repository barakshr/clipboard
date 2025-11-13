import Foundation
import AppKit

enum ClipboardContentType: String, Codable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable {
    let id: String
    let timestamp: Date
    var isFavorite: Bool
    let contentType: ClipboardContentType
    let textContent: String?
    let imageData: Data?
    
    init(id: String = UUID().uuidString, timestamp: Date = Date(), isFavorite: Bool = false, contentType: ClipboardContentType, textContent: String? = nil, imageData: Data? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.contentType = contentType
        self.textContent = textContent
        self.imageData = imageData
    }
    
    var displayText: String {
        switch contentType {
        case .text:
            return textContent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .image:
            return "[Image]"
        }
    }
    
    var image: NSImage? {
        guard let imageData = imageData else { return nil }
        return NSImage(data: imageData)
    }
    
    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch contentType {
        case .text:
            if let text = textContent {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = image {
                pasteboard.writeObjects([image])
            }
        }
    }
}

