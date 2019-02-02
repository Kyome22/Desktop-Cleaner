//
//  CustomImageView.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class CustomImageView: NSImageView {
    
    private var barH: CGFloat = 0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let w: CGFloat = self.frame.width
        let h: CGFloat = self.frame.height
        
        if let context: CGContext = NSGraphicsContext.current?.cgContext {
            context.setBlendMode(CGBlendMode.clear)
            context.addRect(CGRect(x: 0, y: h - barH, width: w, height: barH))
            context.fillPath()
            context.setBlendMode(CGBlendMode.copy)
            NSColor(hex: "B0BEC5", alpha: 0.6).setFill()
            context.addRect(CGRect(x: 0, y: h - barH, width: w, height: 10))
            context.fillPath()
        }
    }
    
    func updateBarH(_ percent: CGFloat) {
        barH = percent * self.frame.height
        self.layer?.setNeedsDisplay()
    }
    
}
