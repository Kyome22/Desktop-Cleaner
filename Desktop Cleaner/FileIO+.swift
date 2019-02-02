//
//  FileIO+.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/01/29.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Foundation

class FileIO {
    
    static func moveFile(isDirectory: Bool, name: String, condition: Condition, destination: String) {
        guard let root = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        let newDir = root.appendingPathComponent(destination)
        if !FileManager.default.fileExists(atPath: newDir.path) {
            do {
                try FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Swift.print(error)
            }
        }
        do {
            var contents = try FileManager.default.contentsOfDirectory(atPath: root.path)
            contents = contents.filter({ (content) -> Bool in
                let url = root.appendingPathComponent(content)
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                    if isDirectory == isDir.boolValue {
                        switch condition {
                        case .include: return content.contains(name)
                        case .begin: return content.hasPrefix(name)
                        case .end: return content.hasSuffix(name)
                        case .isIt: return content == name
                        case .isNot: return content != name
                        }
                    }
                }
                return false
            })
            for content in contents {
                let oldUrl = root.appendingPathComponent(content)
                let newUrl = newDir.appendingPathComponent(content)
                try FileManager.default.moveItem(at: oldUrl, to: newUrl)
            }
        } catch {
            Swift.print(error)
        }
    }
    
    static func removeFile(isDirectory: Bool, name: String, condition: Condition) {
        guard let root = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            var contents = try FileManager.default.contentsOfDirectory(atPath: root.path)
            contents = contents.filter({ (content) -> Bool in
                let url = root.appendingPathComponent(content)
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                    if isDirectory == isDir.boolValue {
                        switch condition {
                        case .include: return content.contains(name)
                        case .begin: return content.hasPrefix(name)
                        case .end: return content.hasSuffix(name)
                        case .isIt: return content == name
                        case .isNot: return content != name
                        }
                    }
                }
                return false
            })
            for content in contents {
                try FileManager.default.removeItem(at: root.appendingPathComponent(content))
            }
        } catch {
            Swift.print(error)
        }
    }
    
    static func moveFile(type: String, condition: Condition, destination: String) {
        guard let root = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        let newDir = root.appendingPathComponent(destination)
        if !FileManager.default.fileExists(atPath: newDir.path) {
            do {
                try FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Swift.print(error)
            }
        }
        do {
            var contents = try FileManager.default.contentsOfDirectory(atPath: root.path)
            contents = contents.filter({ (content) -> Bool in
                let url = root.appendingPathComponent(content)
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        switch condition {
                        case .isIt: return url.pathExtension == type
                        case .isNot: return url.pathExtension != type
                        default: return false
                        }
                    }
                }
                return false
            })
            for content in contents {
                let oldUrl = root.appendingPathComponent(content)
                let newUrl = newDir.appendingPathComponent(content)
                try FileManager.default.moveItem(at: oldUrl, to: newUrl)
            }
        } catch {
            Swift.print(error)
        }
    }
    
    static func removeFile(type: String, condition: Condition) {
        guard let root = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            var contents = try FileManager.default.contentsOfDirectory(atPath: root.path)
            contents = contents.filter({ (content) -> Bool in
                let url = root.appendingPathComponent(content)
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        switch condition {
                        case .isIt: return url.pathExtension == type
                        case .isNot: return url.pathExtension != type
                        default: return false
                        }
                    }
                }
                return false
            })
            for content in contents {
                try FileManager.default.removeItem(at: root.appendingPathComponent(content))
            }
        } catch {
            Swift.print(error)
        }
    }
    
    static func makeDirectory() {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            Swift.print("FileIO Error")
            return
        }
        let url = dir.appendingPathComponent("DesktopCleaner")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Swift.print(error)
            }
        }
    }
    
    static func loadRules() -> [Rule] {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return []
        }
        let url = dir.appendingPathComponent("DesktopCleaner/rules.json")
        if !FileManager.default.fileExists(atPath: url.path) { return [] }
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return [] }
        let array = json as! NSArray
        let rules = array.map { (item) -> Rule in
            let meta = item as! NSDictionary
            let rule = Rule(meta["isDirectory"] as! Bool,
                            meta["isExtension"] as! Bool,
                            meta["name"] as! String,
                            Condition(id: meta["condition"] as! Int)!,
                            meta["isMove"] as! Bool,
                            meta["destination"] as! String)
            return rule
        }
        return rules
    }
    
    static func saveRules(rules: [Rule]) {
        let text = "[" + rules.map({ (rule) -> String in
            return rule.getJSONText()
        }).joined(separator: ",") + "]"
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        let url = dir.appendingPathComponent("DesktopCleaner/rules.json")
        do {
            try text.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            Swift.print(error)
        }
    }
    
}

