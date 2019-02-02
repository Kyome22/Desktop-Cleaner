//
//  Rule.swift
//  Desktop Cleaner
//
//  Created by Takuto Nakamura on 2019/02/03.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Foundation

public enum Condition: Int {
    case include
    case begin
    case end
    case isIt
    case isNot
    
    public init?(id: Int) {
        switch id {
        case 0: self = .include
        case 1: self = .begin
        case 2: self = .end
        case 3: self = .isIt
        case 4: self = .isNot
        default: return nil
        }
    }
}

public struct Rule {
    
    let isDirectory: Bool
    let isExtension: Bool
    let name: String
    let condition: Condition
    let isMove: Bool
    let destination: String
    
    init(_ isDirectory: Bool, _ isExtension: Bool, _ name: String, _ condition: Condition, _ isMove: Bool, _ destination: String) {
        self.isDirectory = isDirectory
        self.isExtension = isExtension
        self.name = name
        self.condition = condition
        self.isMove = isMove
        self.destination = destination
    }
    
    func getJSONText() -> String {
        var str = "{\"isDirectory\":\(self.isDirectory),"
        str += "\"isExtension\":\(self.isExtension),"
        str += "\"name\":\"" + self.name.escaped + "\","
        str += "\"condition\":\(self.condition.rawValue),"
        str += "\"isMove\":\(self.isMove),"
        str += "\"destination\":\"" + self.destination.escaped + "\"}"
        return str
    }
    
    func getItemName() -> String {
        var str = ""
        str += isDirectory ? "フォルダ名が" : (isExtension ? "ファイル拡張子が" : "ファイル名が")
        str += " " + self.name + " "
        switch condition {
        case .include: str += "を含む"
        case .begin: str += "で始まる"
        case .end: str += "で終わる"
        case .isIt: str += "である"
        case .isNot: str += "ではない"
        }
        str += "ならば"
        if isMove {
            str += " " + self.destination + " へ移動する"
        } else {
            str += "削除する"
        }
        return str
    }
    
}
