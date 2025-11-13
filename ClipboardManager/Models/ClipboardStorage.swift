import Foundation
import SQLite

class ClipboardStorage {
    static let shared = ClipboardStorage()
    
    private var db: Connection?
    private let items = Table("clipboard_items")
    private let id = Expression<String>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let isFavorite = Expression<Bool>("is_favorite")
    private let contentType = Expression<String>("content_type")
    private let textContent = Expression<String?>("text_content")
    private let imageData = Expression<Data?>("image_data")
    
    private let maxItems = 100
    
    private init() {}
    
    func initialize() {
        do {
            let path = getDocumentsDirectory().appendingPathComponent("clipboard.sqlite3").path
            db = try Connection(path)
            createTable()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDirectory = paths[0].appendingPathComponent("ClipboardManager")
        
        if !FileManager.default.fileExists(atPath: appSupportDirectory.path) {
            try? FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }
        
        return appSupportDirectory
    }
    
    private func createTable() {
        do {
            try db?.run(items.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(timestamp)
                t.column(isFavorite)
                t.column(contentType)
                t.column(textContent)
                t.column(imageData)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    func saveItem(_ item: ClipboardItem) {
        guard let db = db else { return }
        
        do {
            let insert = items.insert(
                id <- item.id,
                timestamp <- item.timestamp,
                isFavorite <- item.isFavorite,
                contentType <- item.contentType.rawValue,
                textContent <- item.textContent,
                imageData <- item.imageData
            )
            try db.run(insert)
            
            // Clean up old items (keep favorites)
            cleanupOldItems()
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    func updateFavoriteStatus(itemId: String, isFavorite: Bool) {
        guard let db = db else { return }
        
        do {
            let item = items.filter(id == itemId)
            try db.run(item.update(self.isFavorite <- isFavorite))
        } catch {
            print("Error updating favorite status: \(error)")
        }
    }
    
    func getRecentItems(limit: Int = 10) -> [ClipboardItem] {
        guard let db = db else { return [] }
        
        do {
            let query = items.order(timestamp.desc).limit(limit)
            return try db.prepare(query).map { row in
                ClipboardItem(
                    id: row[id],
                    timestamp: row[timestamp],
                    isFavorite: row[isFavorite],
                    contentType: ClipboardContentType(rawValue: row[contentType]) ?? .text,
                    textContent: row[textContent],
                    imageData: row[imageData]
                )
            }
        } catch {
            print("Error fetching recent items: \(error)")
            return []
        }
    }
    
    func getFavorites() -> [ClipboardItem] {
        guard let db = db else { return [] }
        
        do {
            let query = items.filter(isFavorite == true).order(timestamp.desc)
            return try db.prepare(query).map { row in
                ClipboardItem(
                    id: row[id],
                    timestamp: row[timestamp],
                    isFavorite: row[isFavorite],
                    contentType: ClipboardContentType(rawValue: row[contentType]) ?? .text,
                    textContent: row[textContent],
                    imageData: row[imageData]
                )
            }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    func searchItems(query: String, limit: Int = 10) -> [ClipboardItem] {
        guard let db = db, !query.isEmpty else { return getRecentItems(limit: limit) }
        
        do {
            // Search anywhere in text content (case-insensitive)
            let searchQuery = items
                .filter(textContent.like("%\(query)%"))
                .order(timestamp.desc)
                .limit(limit)
            
            return try db.prepare(searchQuery).map { row in
                ClipboardItem(
                    id: row[id],
                    timestamp: row[timestamp],
                    isFavorite: row[isFavorite],
                    contentType: ClipboardContentType(rawValue: row[contentType]) ?? .text,
                    textContent: row[textContent],
                    imageData: row[imageData]
                )
            }
        } catch {
            print("Error searching items: \(error)")
            return []
        }
    }
    
    func getAllItems() -> [ClipboardItem] {
        guard let db = db else { return [] }
        
        do {
            let query = items.order(timestamp.desc)
            return try db.prepare(query).map { row in
                ClipboardItem(
                    id: row[id],
                    timestamp: row[timestamp],
                    isFavorite: row[isFavorite],
                    contentType: ClipboardContentType(rawValue: row[contentType]) ?? .text,
                    textContent: row[textContent],
                    imageData: row[imageData]
                )
            }
        } catch {
            print("Error fetching all items: \(error)")
            return []
        }
    }
    
    func clearHistory() {
        guard let db = db else { return }
        
        do {
            // Delete only non-favorite items
            let nonFavorites = items.filter(isFavorite == false)
            try db.run(nonFavorites.delete())
        } catch {
            print("Error clearing history: \(error)")
        }
    }
    
    private func cleanupOldItems() {
        guard let db = db else { return }
        
        do {
            // Get count of non-favorite items
            let nonFavorites = items.filter(isFavorite == false)
            let count = try db.scalar(nonFavorites.count)
            
            if count > maxItems {
                // Delete oldest non-favorite items
                let itemsToDelete = count - maxItems
                let oldestItems = nonFavorites
                    .order(timestamp.asc)
                    .limit(itemsToDelete)
                
                for item in try db.prepare(oldestItems) {
                    let itemToDelete = items.filter(id == item[self.id])
                    try db.run(itemToDelete.delete())
                }
            }
        } catch {
            print("Error cleaning up old items: \(error)")
        }
    }
    
    func isDuplicate(_ newItem: ClipboardItem) -> Bool {
        let recentItems = getRecentItems(limit: 1)
        guard let lastItem = recentItems.first else { return false }
        
        // Check if content is the same
        if newItem.contentType != lastItem.contentType {
            return false
        }
        
        switch newItem.contentType {
        case .text:
            return newItem.textContent == lastItem.textContent
        case .image:
            return newItem.imageData == lastItem.imageData
        }
    }
}

