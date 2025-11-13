# macOS Clipboard Manager - Implementation Plan

## Overview
A native macOS clipboard manager app built with Swift and AppKit that runs in the menu bar, monitors clipboard changes, stores history, and provides quick access via a configurable keyboard shortcut.

## Requirements Summary
- Store last 100 clipboard items (text and images)
- Display last 10 items by default
- Search functionality (prefix search, max 10 results)
- Favorite items that persist indefinitely
- Configurable keyboard shortcut (default: Ctrl + `)
- Popup window at remembered location
- Auto-dismiss when clicking outside
- Settings window for configuration
- Launch at login capability
- Run silently in menu bar

## Implementation Steps

### Phase 1: Project Setup & Foundation

#### Step 1.1: Create Xcode Project
- Create a new macOS App project in Xcode
- Configure as a menu bar (status bar) application
- Set minimum macOS version to 12.0 (Monterey)
- Configure app to run as "accessory" (LSUIElement = true in Info.plist)
- **Deliverable**: Basic Xcode project structure

#### Step 1.2: Set Up Data Model
- Create `ClipboardItem` model with properties: id, content, timestamp, isFavorite, contentType
- Create `ClipboardStorage` manager class for CRUD operations
- Implement SQLite database for persistence (using SQLite.swift library)
- **Deliverable**: Data models and storage layer

#### Step 1.3: Add Required Dependencies
- Add SQLite.swift via Swift Package Manager
- Add HotKey library for global keyboard shortcuts
- **Deliverable**: Dependencies integrated

### Phase 2: Core Clipboard Monitoring

#### Step 2.1: Implement Clipboard Monitor
- Create `ClipboardMonitor` class using NSPasteboard.general
- Poll clipboard every 0.5 seconds for changes
- Detect text and image content types
- **Deliverable**: Working clipboard monitoring

#### Step 2.2: Integrate Storage with Monitor
- Connect clipboard monitor to storage manager
- Implement 100-item limit with FIFO deletion (excluding favorites)
- Handle duplicate detection
- **Deliverable**: Clipboard changes automatically saved

### Phase 3: User Interface - Main Popup Window

#### Step 3.1: Create Popup Window
- Build NSWindow with borderless style and floating level
- Create NSViewController for clipboard list
- Use NSTableView to display clipboard items
- Show last 10 items by default
- **Deliverable**: Popup window displaying recent items

#### Step 3.2: Implement Search Functionality
- Add NSSearchField at top of popup
- Implement prefix search filtering
- Limit search results to 10 items
- **Deliverable**: Working search with real-time filtering

#### Step 3.3: Add Favorite Toggle
- Add star/favorite button to each item
- Implement toggle functionality
- Update database when favorite status changes
- **Deliverable**: Favorite marking and persistence

#### Step 3.4: Implement Click-to-Copy
- Handle item selection
- Copy selected item back to system clipboard
- Close popup window after selection
- **Deliverable**: Selecting an item copies it

#### Step 3.5: Window Position Persistence
- Save window position to UserDefaults when moved
- Restore window position on next open
- **Deliverable**: Window position persists

#### Step 3.6: Auto-Dismiss on Outside Click
- Implement window deactivation detection
- Close window when user clicks outside
- **Deliverable**: Window auto-closes when losing focus

### Phase 4: Global Keyboard Shortcut

#### Step 4.1: Implement Shortcut Handler
- Create `ShortcutManager` using HotKey library
- Set default shortcut to Ctrl + `
- Register global keyboard event listener
- Show/hide popup window when shortcut triggered
- **Deliverable**: Ctrl + ` opens/closes popup window

#### Step 4.2: Save/Load Shortcut Configuration
- Store keyboard shortcut in UserDefaults
- Load saved shortcut on app launch
- **Deliverable**: Shortcut configuration persists

### Phase 5: Settings Window

#### Step 5.1: Create Settings Window UI
- Build NSWindow for settings
- Add keyboard shortcut configurator
- Add "Launch at Login" checkbox
- Add "Clear History" button
- **Deliverable**: Settings window with all options

#### Step 5.2: Implement Launch at Login
- Use ServiceManagement framework
- Add toggle functionality in settings
- **Deliverable**: Launch at login working

### Phase 6: Menu Bar Integration

#### Step 6.1: Create Menu Bar Item
- Create NSStatusItem with icon
- Design simple clipboard icon
- **Deliverable**: Menu bar icon appears

#### Step 6.2: Build Menu Bar Menu
- Add menu items: "Open", "Settings", "Quit"
- Connect menu items to actions
- **Deliverable**: Functional menu bar dropdown

### Phase 7: Permissions & Polish

#### Step 7.1: Request Necessary Permissions
- Add accessibility permission request
- Handle permission denial gracefully
- **Deliverable**: Proper permission handling

#### Step 7.2: Error Handling & Edge Cases
- Handle database errors
- Handle large clipboard content
- Handle empty clipboard state
- **Deliverable**: Robust error handling

#### Step 7.3: UI Polish
- Add smooth animations
- Add keyboard navigation
- Ensure dark mode support
- **Deliverable**: Polished UI

### Phase 8: Testing & Documentation

#### Step 8.1: Testing
- Test all features comprehensively
- Test edge cases
- **Deliverable**: Verified working app

#### Step 8.2: Create README
- Document installation and usage
- Include troubleshooting
- **Deliverable**: Complete README.md

## Technology Stack
- **Language**: Swift 5.9+
- **Framework**: AppKit (native macOS)
- **Database**: SQLite via SQLite.swift
- **Shortcuts**: HotKey library
- **Build Tool**: Xcode 15+

## Status
Plan approved and ready for execution.

