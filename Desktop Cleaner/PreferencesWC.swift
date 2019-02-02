//
//  PreferencesWC.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class PreferencesWC: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.delegate = self
    }
    
    func windowWillClose(_ notification: Notification) {
        AppDelegate.shared.closeWindow()
    }

}
