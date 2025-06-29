//
//  Genre.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/29.
//

import SwiftUI
import SwiftData


@Model
class Genre {
    var name: String
    var color: String
    
    // 多对多
    var book: [Book]?
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
    var hexColor: Color {
        Color(hex: self.color) ?? .red
    }
}
