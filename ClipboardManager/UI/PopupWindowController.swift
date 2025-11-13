import Cocoa

class PopupWindowController: NSWindowController {
    private var popupViewController: PopupViewController!
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Clipboard Manager"
        window.level = .floating
        window.isReleasedWhenClosed = false
        
        self.init(window: window)
        
        popupViewController = PopupViewController()
        window.contentViewController = popupViewController
        
        // Load saved position
        loadWindowPosition()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        popupViewController.focusSearchField()
        popupViewController.reloadData()
    }
    
    override func close() {
        saveWindowPosition()
        super.close()
    }
    
    private func saveWindowPosition() {
        guard let window = window else { return }
        let frame = window.frame
        UserDefaults.standard.set(frame.origin.x, forKey: "windowX")
        UserDefaults.standard.set(frame.origin.y, forKey: "windowY")
    }
    
    private func loadWindowPosition() {
        guard let window = window else { return }
        
        let x = UserDefaults.standard.double(forKey: "windowX")
        let y = UserDefaults.standard.double(forKey: "windowY")
        
        if x != 0 || y != 0 {
            window.setFrameOrigin(NSPoint(x: x, y: y))
        } else {
            window.center()
        }
    }
}

class PopupViewController: NSViewController {
    private var searchField: NSSearchField!
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    private var favoritesButton: NSButton!
    
    private var items: [ClipboardItem] = []
    private var isSearching = false
    private var showingFavoritesOnly = false
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadItems()
        
        // Monitor window deactivation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: view.window
        )
    }
    
    private func setupUI() {
        // Favorites filter button
        favoritesButton = NSButton(frame: NSRect(x: 20, y: view.bounds.height - 50, width: 100, height: 30))
        favoritesButton.title = "⭐ Favorites"
        favoritesButton.bezelStyle = .rounded
        favoritesButton.target = self
        favoritesButton.action = #selector(toggleFavoritesFilter)
        favoritesButton.autoresizingMask = .minYMargin
        view.addSubview(favoritesButton)
        
        // Search field with custom subclass for key handling
        searchField = ClipboardSearchField(frame: NSRect(x: 130, y: view.bounds.height - 50, width: view.bounds.width - 150, height: 30))
        searchField.placeholderString = "Search clipboard history..."
        searchField.autoresizingMask = [.width, .minYMargin]
        searchField.target = self
        searchField.action = #selector(searchFieldChanged)
        (searchField as? ClipboardSearchField)?.parentViewController = self
        view.addSubview(searchField)
        
        // Table view
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 70))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        
        tableView = NSTableView(frame: scrollView.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .regular
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick)
        
        // Column
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ClipboardColumn"))
        column.width = scrollView.bounds.width
        tableView.addTableColumn(column)
        tableView.headerView = nil
        
        scrollView.documentView = tableView
        view.addSubview(scrollView)
    }
    
    @objc private func toggleFavoritesFilter() {
        showingFavoritesOnly = !showingFavoritesOnly
        
        // Update button appearance
        if showingFavoritesOnly {
            favoritesButton.title = "★ Favorites"
            favoritesButton.bezelColor = .systemBlue
            searchField.placeholderString = "Search favorites..."
        } else {
            favoritesButton.title = "⭐ Favorites"
            favoritesButton.bezelColor = nil
            searchField.placeholderString = "Search clipboard history..."
        }
        
        // Clear search and reload
        searchField.stringValue = ""
        isSearching = false
        loadItems()
    }
    
    @objc private func searchFieldChanged() {
        let query = searchField.stringValue
        
        if query.isEmpty {
            isSearching = false
            loadItems()
        } else {
            isSearching = true
            if showingFavoritesOnly {
                // Search within favorites only
                let allFavorites = ClipboardStorage.shared.getFavorites()
                items = allFavorites.filter { item in
                    item.textContent?.localizedCaseInsensitiveContains(query) ?? false
                }
            } else {
                items = ClipboardStorage.shared.searchItems(query: query, limit: 10)
            }
            tableView.reloadData()
        }
        
        // Always select first result for easy keyboard navigation
        if items.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    private func loadItems() {
        if showingFavoritesOnly {
            items = ClipboardStorage.shared.getFavorites()
        } else {
            items = ClipboardStorage.shared.getRecentItems(limit: 10)
        }
        tableView.reloadData()
    }
    
    @objc private func tableViewDoubleClick() {
        let row = tableView.clickedRow
        guard row >= 0, row < items.count else { return }
        
        copyItemAndClose(at: row)
    }
    
    private func copyItemAndClose(at row: Int) {
        guard row >= 0, row < items.count else { return }
        
        let item = items[row]
        item.copyToClipboard()
        
        NSLog("📋 Copied to clipboard: \(item.displayText.prefix(50))...")
        
        // Close window
        view.window?.close()
    }
    
    @objc private func windowDidResignKey(_ notification: Notification) {
        // Close window when it loses focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.view.window?.close()
        }
    }
    
    func focusSearchField() {
        view.window?.makeFirstResponder(searchField)
        searchField.stringValue = ""
        
        // Select first row by default for keyboard navigation
        if items.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    func reloadData() {
        loadItems()
        // Select first row after reload
        if items.count > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    @objc private func toggleFavorite(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard row >= 0, row < items.count else { return }
        
        let item = items[row]
        let newFavoriteStatus = !item.isFavorite
        ClipboardStorage.shared.updateFavoriteStatus(itemId: item.id, isFavorite: newFavoriteStatus)
        
        // Reload data
        if isSearching {
            searchFieldChanged()
        } else {
            loadItems()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: // Escape key
            view.window?.close()
            
        case 36: // Return/Enter key
            let selectedRow = tableView.selectedRow
            if selectedRow >= 0 {
                copyItemAndClose(at: selectedRow)
            }
            
        case 125: // Down arrow
            if tableView.selectedRow < items.count - 1 {
                tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow + 1), byExtendingSelection: false)
                tableView.scrollRowToVisible(tableView.selectedRow)
            }
            
        case 126: // Up arrow
            if tableView.selectedRow > 0 {
                tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow - 1), byExtendingSelection: false)
                tableView.scrollRowToVisible(tableView.selectedRow)
            }
            
        default:
            super.keyDown(with: event)
        }
    }
}

extension PopupViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
}

extension PopupViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = items[row]
        
        let cellView = ClipboardCellView(frame: NSRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
        cellView.configure(with: item)
        cellView.favoriteButton.target = self
        cellView.favoriteButton.action = #selector(toggleFavorite(_:))
        
        return cellView
    }
}

class ClipboardCellView: NSView {
    private let contentLabel = NSTextField(labelWithString: "")
    private let timestampLabel = NSTextField(labelWithString: "")
    private let imageView = NSImageView()
    let favoriteButton = NSButton()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Content label
        contentLabel.frame = NSRect(x: 10, y: 20, width: frame.width - 60, height: 20)
        contentLabel.font = .systemFont(ofSize: 13)
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.autoresizingMask = .width
        addSubview(contentLabel)
        
        // Timestamp label
        timestampLabel.frame = NSRect(x: 10, y: 5, width: frame.width - 60, height: 15)
        timestampLabel.font = .systemFont(ofSize: 10)
        timestampLabel.textColor = .secondaryLabelColor
        timestampLabel.autoresizingMask = .width
        addSubview(timestampLabel)
        
        // Image view
        imageView.frame = NSRect(x: 10, y: 10, width: 40, height: 40)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.isHidden = true
        addSubview(imageView)
        
        // Favorite button
        favoriteButton.frame = NSRect(x: frame.width - 45, y: 15, width: 35, height: 30)
        favoriteButton.bezelStyle = .inline
        favoriteButton.isBordered = false
        favoriteButton.autoresizingMask = .minXMargin
        favoriteButton.toolTip = "Mark as favorite (never deleted)"
        addSubview(favoriteButton)
    }
    
    func configure(with item: ClipboardItem) {
        switch item.contentType {
        case .text:
            contentLabel.isHidden = false
            imageView.isHidden = true
            contentLabel.stringValue = item.displayText
            contentLabel.frame = NSRect(x: 10, y: 20, width: frame.width - 60, height: 20)
        case .image:
            contentLabel.isHidden = false
            imageView.isHidden = false
            contentLabel.stringValue = "[Image]"
            imageView.image = item.image
            contentLabel.frame = NSRect(x: 60, y: 20, width: frame.width - 110, height: 20)
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timestampLabel.stringValue = formatter.localizedString(for: item.timestamp, relativeTo: Date())
        
        // Use SF Symbol if available, fallback to emoji
        if let starImage = NSImage(systemSymbolName: item.isFavorite ? "star.fill" : "star", accessibilityDescription: "Favorite") {
            favoriteButton.image = starImage
            favoriteButton.title = ""
        } else {
            favoriteButton.image = nil
            favoriteButton.title = item.isFavorite ? "★" : "☆"
            favoriteButton.font = .systemFont(ofSize: 16)
        }
    }
}

// Custom search field that forwards arrow keys and Enter to parent
class ClipboardSearchField: NSSearchField {
    weak var parentViewController: PopupViewController?
    
    override func keyDown(with event: NSEvent) {
        let keyCode = event.keyCode
        
        // Forward navigation keys to parent view controller
        switch keyCode {
        case 125, 126, 36, 53: // Down, Up, Enter, Escape
            parentViewController?.keyDown(with: event)
        default:
            super.keyDown(with: event)
        }
    }
}
