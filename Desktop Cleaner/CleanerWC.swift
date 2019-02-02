//
//  CleanerWC.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class CleanerWC: NSWindowController, NSWindowDelegate {
    
    public var frame: NSRect = NSRect.zero {
        didSet {
            if let window_ = self.window {
                window_.setFrame(frame, display: true)
            }
            if let vc = self.contentViewController as? CleanerVC {
                vc.setImage(frame.origin)
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.delegate = self
        self.window!.isOpaque = false
        self.window!.backgroundColor = NSColor(hex: "000000", alpha: 0.01)
        self.window!.level = NSWindow.Level(Int(CGWindowLevelForKey(CGWindowLevelKey.desktopIconWindow)))
    }
    
    func windowWillClose(_ notification: Notification) {
        self.contentViewController = nil
    }
    
    public func tellGoDown() {
        if let vc = self.contentViewController as? CleanerVC {
            vc.goDown()
        }
    }

}
