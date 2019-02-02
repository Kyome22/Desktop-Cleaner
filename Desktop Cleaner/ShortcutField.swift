//
//  ShortcutField.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

protocol ShortcutFieldDelegate: NSTextFieldDelegate {
    func didPressKey(event: NSEvent)
    func didChangeFlag(event: NSEvent)
}

class ShortcutField: NSTextField {
    
    var delegate_: ShortcutFieldDelegate?
    var monitors = [Any?]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.placeholderString = "Type Shortcut"
        self.isBordered = true
        self.isSelectable = false
        self.wantsLayer = true
        self.layer?.borderColor = NSColor(hex: "B0BEC5").cgColor
        self.layer?.borderWidth = 1.0
        self.layer?.cornerRadius = 4.0
    }
    
    override func becomeFirstResponder() -> Bool {
        if monitors.count == 0 {
            monitors.append(NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { (event) -> NSEvent? in
                self.delegate_?.didPressKey(event: event)
                return event
            })
            monitors.append(NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged) { (event) -> NSEvent? in
                self.delegate_?.didChangeFlag(event: event)
                return event
            })
        }
        return true
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    public func removeMonitor() {
        for monitor in monitors {
            NSEvent.removeMonitor(monitor!)
        }
        monitors.removeAll()
    }
    
    override func resetCursorRects() {
        let rectL = NSRect(x: 0, y: 0, width: bounds.width - 25, height: 25)
        let cursorL: NSCursor = NSCursor.iBeam
        addCursorRect(rectL, cursor: cursorL)
        
        let rectR = NSRect(x: bounds.width - 25, y: 0, width: 25, height: 25)
        let cursorR: NSCursor = NSCursor.pointingHand
        addCursorRect(rectR, cursor: cursorR)
    }
    
}
