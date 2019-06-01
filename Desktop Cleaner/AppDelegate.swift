//
//  AppDelegate.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/01/29.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa
import SpiceKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var storyboard: NSStoryboard? = nil
    private let userDefaults = UserDefaults.standard
    private var rules = [Rule]()
    private var spiceKey: SpiceKey? = nil
    private var preferencesWC: PreferencesWC?
    
    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        let icon = NSImage(imageLiteralResourceName: "StatusIcon")
        icon.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = menu
        
        let preferenceItem = menu.item(withTag: 0)
        preferenceItem?.target = self
        preferenceItem?.action = #selector(AppDelegate.openPreferences)
        
        let cleanItem = menu.item(withTag: 1)
        cleanItem?.target = self
        cleanItem?.action = #selector(AppDelegate.clean)
        
        let quitItem = menu.item(withTag: 2)
        quitItem?.target = self
        quitItem?.action = #selector(AppDelegate.quitApp)
        
        setHotKey()
        
        FileIO.makeDirectory()
        rules = FileIO.loadRules()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        spiceKey?.unregister()
    }
    
    @objc func openPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        if preferencesWC == nil {
            preferencesWC = storyboard!.instantiateController(withIdentifier: "preferencesWC") as? PreferencesWC
            preferencesWC?.showWindow(self)
        } else {
            preferencesWC!.window?.orderFront(self)
        }
    }
    
    public func closeWindow() {
        preferencesWC?.contentViewController = nil
        preferencesWC = nil
    }
    
    @objc func clean() {
        
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    public func setHotKey(key: Key, flags: ModifierFlags) {
        let keyCombination = KeyCombination(key, flags)
        spiceKey?.unregister()
        spiceKey = SpiceKey(keyCombination, keyDownHandler: {
            self.ordering()
        })
        spiceKey!.register()
        userDefaults.set(key.keyCode,  forKey: "keyCode")
        userDefaults.set(flags.string, forKey: "flagStr")
        userDefaults.synchronize()
    }
    
    private func setHotKey() {
        guard let keyCode = userDefaults.object(forKey: "keyCode") as? UInt16,
            let flagStr = userDefaults.object(forKey: "flagStr") as? String else {
                return
        }
        var flags = ModifierFlags.empty
        switch flagStr {
        case "⌃": flags = .ctrl
        case "⌥": flags = .opt
        case "⇧": flags = .sft
        case "⌘": flags = .cmd
        case "⌃⌥": flags = .ctrlOpt
        case "⌃⇧": flags = .ctrlSft
        case "⌃⌘": flags = .ctrlCmd
        case "⌥⇧": flags = .optSft
        case "⌥⌘": flags = .optCmd
        case "⇧⌘": flags = .sftCmd
        case "⌃⌥⇧": flags = .ctrlOptSft
        case "⌃⌥⌘": flags = .ctrlOptCmd
        case "⌃⇧⌘": flags = .ctrlSftCmd
        case "⌥⇧⌘": flags = .optSftCmd
        case "⌃⌥⇧⌘": flags = .ctrlOptSftCmd
        default: return
        }
        self.setHotKey(key: Key(keyCode: keyCode)!, flags: flags)
    }
    
    public func removeHotKey() {
        spiceKey?.unregister()
        userDefaults.removeObject(forKey: "keyCode")
        userDefaults.removeObject(forKey: "flagStr")
        userDefaults.synchronize()
    }
    
    public func referHotKey() -> (keyStr: String, flagStr: String)? {
        guard let keyCode = userDefaults.object(forKey: "keyCode") as? UInt16,
            let flagStr = userDefaults.object(forKey: "flagStr") as? String else {
                return nil
        }
        return (Key(keyCode: keyCode)!.string, flagStr)
    }
    
    public func referRules() -> [Rule] {
        return self.rules
    }
    
    public func updatedRules(rules: [Rule]) {
        self.rules = rules
        FileIO.saveRules(rules: rules)
    }

    
    @objc func ordering() {
        rules.forEach { (rule) in
            if rule.isExtension {
                if rule.isMove {
                    FileIO.moveFile(type: rule.name, condition: rule.condition, destination: rule.destination)
                } else {
                    FileIO.removeFile(type: rule.name, condition: rule.condition)
                }
            } else {
                if rule.isMove {
                    FileIO.moveFile(isDirectory: rule.isDirectory, name: rule.name, condition: rule.condition, destination: rule.destination)
                } else {
                    FileIO.removeFile(isDirectory: rule.isDirectory, name: rule.name, condition: rule.condition)
                }
            }
        }
    }
    
}
