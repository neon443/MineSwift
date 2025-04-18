//
//  Item.swift
//  MineSwift
//
//  Created by Nihaal Sharma on 31/12/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
