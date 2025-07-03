//
//  Quote.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/27.
//

import Foundation
import SwiftData

@Model
class Quote {
    
    var creationDate: Date = Date.now
    var text: String = ""
    var page: String?
    
    init(text: String, page: String? = nil) {
        self.text = text
        self.page = page
    }
    
    // 一对多
    var book: Book?
    
}
