//
//  AppDelegate.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/01/29.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var storyboard: NSStoryboard? = nil
    private let userDefaults = UserDefaults.standard
    private var hotkey: HotKey? = nil
    private var rules = [Rule]()
    
    private var cleanerWCs = [CleanerWC]()
    private var preferencesWC: PreferencesWC?
    private var counter: Int = 0
    
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
        for screen in NSScreen.screens {
            guard let cleanerWC = storyboard!.instantiateController(withIdentifier: "cleanerWC") as? CleanerWC else {
                continue
            }
            cleanerWCs.append(cleanerWC)
            cleanerWC.frame = screen.frame
            cleanerWC.showWindow(self)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    private func setHotKey() {
        let keyStr: String? = userDefaults.object(forKey: "keyStr") as? String
        let flagStr: String? = userDefaults.object(forKey: "flagStr") as? String
        if (keyStr != nil && flagStr != nil), let key = Key(string: keyStr!) {
            hotkey = nil
            hotkey = HotKey(key: key, modifiers: decodeFlags(flagStr!))
            hotkey?.keyDownHandler = {
                self.clean()
            }
        }
    }
    
    public func setHotKey(keyStr: String, flagStr: String, flags: NSEvent.ModifierFlags) -> Bool {
        if let key = Key(string: keyStr) {
            hotkey = nil
            hotkey = HotKey(key: key, modifiers: flags)
            hotkey?.keyDownHandler = {
                self.clean()
            }
            userDefaults.set(keyStr,  forKey: "keyStr")
            userDefaults.set(flagStr, forKey: "flagStr")
            userDefaults.synchronize()
            return true
        }
        return false
    }
    
    public func removeHotKey() {
        hotkey = nil
        userDefaults.removeObject(forKey: "keyStr")
        userDefaults.removeObject(forKey: "flagStr")
        userDefaults.synchronize()
    }
    
    private func decodeFlags(_ flagStr: String) -> NSEvent.ModifierFlags {
        switch flagStr {
        case "⇧":   return .shift
        case "⌃":   return .control
        case "⌥":   return .option
        case "⌘":   return .command
        case "⇧⌃":  return [.shift,   .control]
        case "⇧⌥":  return [.shift,   .option]
        case "⇧⌘":  return [.shift,   .command]
        case "⌃⌥":  return [.control, .option]
        case "⌃⌘":  return [.control, .command]
        case "⌥⌘":  return [.option,  .command]
        case "⇧⌃⌥": return [.shift,   .control, .option]
        case "⇧⌃⌘": return [.shift,   .control, .command]
        case "⇧⌥⌘": return [.shift,   .option,  .command]
        case "⌃⌥⌘": return [.control, .option,  .command]
        case "⇧⌃⌥⌘": return [.shift,  .control, .option, .command]
        default: return []
        }
    }
    
    public func referHotKey() -> (keyStr: String, flagStr: String)? {
        let keyStr: String? = userDefaults.object(forKey: "keyStr") as? String
        let flagStr: String? = userDefaults.object(forKey: "flagStr") as? String
        if keyStr != nil && flagStr != nil {
            return (keyStr!, flagStr!)
        } else {
            return nil
        }
    }
    
    public func referRules() -> [Rule] {
        return self.rules
    }
    
    public func updatedRules(rules: [Rule]) {
        self.rules = rules
        FileIO.saveRules(rules: rules)
    }
    
    public func tellGoUpped() {
        counter += 1
        if counter == cleanerWCs.count {
            counter = 0
            ordering()
        }
    }
    
    private func ordering() {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.cleanerWCs.forEach { (cleanerWC) in
                cleanerWC.tellGoDown()
            }
            self.cleanerWCs.removeAll()
        }
    }
    
}
