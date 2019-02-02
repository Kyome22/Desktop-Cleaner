//
//  CleanerVC.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa

class CleanerVC: NSViewController {
    
    @IBOutlet weak var imageView: CustomImageView!
    private var image: NSImage?
    private var timer: Timer?
    private var count: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.wantsLayer = true
    }
    
    override func viewDidAppear() {
        goUp()
    }
    
    override func viewWillDisappear() {
        timer?.invalidate()
        
    }
    
    public func setImage(_ point: CGPoint) {
        image = NSImage.desktopPicture(targetPoint: point)
        imageView.image = image?.resize(targetSize: self.view.bounds.size)
    }
    
    private func goUp() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (t) in
            self.count += 1
            self.imageView.updateBarH(1 - self.count / 50)
            if self.count == 50 {
                self.timer?.invalidate()
                AppDelegate.shared.tellGoUpped()
            }
        })
        timer?.fire()
    }
    
    public func goDown() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (t) in
            self.count -= 1
            self.imageView.updateBarH(1 - self.count / 50)
            if self.count == 0 {
                self.timer?.invalidate()
                self.fadeOut()
            }
        })
        timer?.fire()
    }
    
    public func fadeOut() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.imageView.animator().alphaValue = 0
        }) {
            self.view.window?.close()
        }
    }
    
    
}
