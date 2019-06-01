//
//  PreferencesVC.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/02.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Cocoa
import SpiceKey

class PreferencesVC: NSViewController, ShortcutFieldDelegate, NSTextFieldDelegate {

    @IBOutlet weak var shortcutField: ShortcutField!
    @IBOutlet weak var deleteBtn: DeleteButton!
    
    @IBOutlet weak var nameFieldL: NSTextField!
    @IBOutlet weak var nameFieldR: NSTextField!
    @IBOutlet weak var nameAddBtn: NSButton!
    @IBOutlet weak var isDirectoryPopUp: NSPopUpButton!
    @IBOutlet weak var nameConditionPopUp: NSPopUpButton!
    @IBOutlet weak var nameIsMovePopUp: NSPopUpButton!
    
    @IBOutlet weak var extensionFieldL: NSTextField!
    @IBOutlet weak var extensionFieldR: NSTextField!
    @IBOutlet weak var extensionAddBtn: NSButton!
    @IBOutlet weak var extensionConditionPopUp: NSPopUpButton!
    @IBOutlet weak var extensionIsMovePopUp: NSPopUpButton!
    
    @IBOutlet weak var ruleTableView: NSTableView!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    private var rules = [Rule]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shortcutField.delegate_ = self
        ruleTableView.delegate = self
        ruleTableView.dataSource = self
        ruleTableView.registerForDraggedTypes([NSPasteboard.PasteboardType("public.data")])
        
        if let hotkey = AppDelegate.shared.referHotKey() {
            shortcutField.stringValue = hotkey.flagStr + hotkey.keyStr
            shortcutField.isEditable = false
        } else {
            shortcutField.stringValue = ""
            shortcutField.isEditable = true
            deleteBtn.setArrow()
        }
        
        nameFieldL.delegate = self
        nameFieldR.delegate = self
        extensionFieldL.delegate = self
        extensionFieldR.delegate = self
        nameAddBtn.isEnabled = false
        extensionAddBtn.isEnabled = false
        
        rules = AppDelegate.shared.referRules()
        ruleTableView.reloadData()
        segmentedControl.setEnabled(false, forSegment: 0)
    }
    
    override func viewWillDisappear() {
        shortcutField.removeMonitor()
    }
    
    @IBAction func deleteHotKey(_ sender: Any) {
        shortcutField.stringValue = ""
        shortcutField.isEditable = true
        deleteBtn.setArrow()
        AppDelegate.shared.removeHotKey()
    }
    
    func didPressKey(event: NSEvent) {
        let flags = event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask)
        guard let modifierFlags = ModifierFlags(flags: flags), !modifierFlags.string.isEmpty else {
            shortcutField.stringValue = ""
            deleteBtn.setArrow()
            return
        }
        if let key = Key(keyCode: event.keyCode), shortcutField.stringValue.replacingOccurrences(of: modifierFlags.string, with: "").isEmpty {
            AppDelegate.shared.setHotKey(key: key, flags: modifierFlags)
            shortcutField.stringValue = modifierFlags.string + key.string
            shortcutField.abortEditing()
            shortcutField.isEditable = false
            deleteBtn.setDelete()
        }
    }
    
    func didChangeFlag(event: NSEvent) {
        if AppDelegate.shared.referHotKey() == nil {
            let flags = event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask)
            guard let modifierFlags = ModifierFlags(flags: flags) else { return }
            shortcutField.stringValue = modifierFlags.string
            shortcutField.currentEditor()?.selectedRange = NSMakeRange(shortcutField.stringValue.count, 0)
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        nameAddBtn.isEnabled = nameFieldL.stringValue.count > 0
            && (nameFieldR.stringValue.count > 0 || nameFieldR.isHidden)
        extensionAddBtn.isEnabled = extensionFieldL.stringValue.count > 0
            && (extensionFieldR.stringValue.count > 0 || extensionFieldR.isHidden)
    }
    
    @IBAction func selectedIsMove(_ sender: NSPopUpButton) {
        if sender.tag == 0 {
            nameFieldR.isHidden = (sender.indexOfSelectedItem == 1)
            if nameFieldR.isHidden { nameFieldR.stringValue = "" }
            nameAddBtn.isEnabled = nameFieldL.stringValue.count > 0
                && (nameFieldR.stringValue.count > 0 || nameFieldR.isHidden)
        } else {
            extensionFieldR.isHidden = (sender.indexOfSelectedItem == 1)
            if extensionFieldR.isHidden { extensionFieldR.stringValue = "" }
            extensionAddBtn.isEnabled = extensionFieldL.stringValue.count > 0
                && (extensionFieldR.stringValue.count > 0 || extensionFieldR.isHidden)
        }
    }
    
    @IBAction func addRule(_ sender: NSButton) {
        if sender.tag == 0 {
            let rule = Rule(isDirectoryPopUp.indexOfSelectedItem == 1, false, nameFieldL.stringValue,
                            Condition(id: nameConditionPopUp.selectedTag())!,
                            nameIsMovePopUp.indexOfSelectedItem == 0, nameFieldR.stringValue)
            rules.append(rule)
        } else {
            let rule = Rule(false, true, extensionFieldL.stringValue, Condition(id: extensionConditionPopUp.selectedTag())!,
                            extensionIsMovePopUp.indexOfSelectedItem == 0, extensionFieldR.stringValue)
            rules.append(rule)
        }
        ruleTableView.reloadData()
        AppDelegate.shared.updatedRules(rules: rules)
    }
    
    @IBAction func removeRule(_ sender: Any) {
        rules.remove(at: ruleTableView.selectedRow)
        ruleTableView.reloadData()
        segmentedControl.setEnabled(false, forSegment: 0)
        AppDelegate.shared.updatedRules(rules: rules)
    }

}


extension PreferencesVC: NSTableViewDelegate, NSTableViewDataSource {
   
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rules.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = ruleTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RuleCell"), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = rules[row].getItemName()
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        segmentedControl.setEnabled(true, forSegment: 0)
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        for i in (0 ..< rules.count) {
            if ruleTableView.isRowSelected(i) {
                return
            }
        }
        segmentedControl.setEnabled(false, forSegment: 0)
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: rowIndexes, requiringSecureCoding: false)
            pboard.declareTypes([NSPasteboard.PasteboardType("public.data")], owner: self)
            pboard.setData(data, forType: NSPasteboard.PasteboardType("public.data"))
        } catch {
            Swift.print(error)
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        if let pboardData = pboard.data(forType: NSPasteboard.PasteboardType("public.data")) {
            do {
                if let rowIndexes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(pboardData) as? IndexSet {
                    ruleTableView.beginUpdates()
                    for oldRow in rowIndexes {
                        if oldRow < row {
                            ruleTableView.moveRow(at: oldRow, to: row - 1)
                            rules.swapAt(oldRow, row - 1)
                        } else if row < rules.count {
                            ruleTableView.moveRow(at: oldRow, to: row)
                            rules.swapAt(oldRow, row)
                        }
                    }
                    ruleTableView.endUpdates()
                    AppDelegate.shared.updatedRules(rules: rules)
                    return true
                }
            } catch {
                Swift.print(error)
            }
        }
        return false
    }
    
}
