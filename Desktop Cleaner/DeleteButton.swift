//
//  DeleteButton.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class DeleteButton: NSButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isBordered = false
        self.wantsLayer = true
        self.image = NSImage(imageLiteralResourceName: "delete1")
        self.alternateImage = NSImage(imageLiteralResourceName: "delete0")
        self.imagePosition = NSButton.ImagePosition.imageOnly
        self.imageScaling = NSImageScaling.scaleProportionallyDown
    }
    
    func setArrow() {
        self.image = NSImage(imageLiteralResourceName: "arrow")
        self.image?.isTemplate = true
        self.isEnabled = false
    }
    
    func setDelete() {
        self.image = NSImage(imageLiteralResourceName: "delete1")
        self.isEnabled = true
    }
    
}
