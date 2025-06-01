//
//  Book.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/5/31.
//

import Foundation

import SwiftData
import SwiftUI

@Model
class Book {
    var title: String
    var author: String
    var dateAdded: Date
    var dateStarted: Date
    var dateCompleted: Date
    var summary: String
    var rating: Int?
    var status: Status
    
    // 初始化；title和author为必填项，其它属性设置了默认值
    init(
        title: String,
        author: String,
        dateAdded: Date = Date.now,
        dateStarted: Date = Date.distantPast,  // 通常用于表示“尚未完成”、“默认无效时间”或“初始值”。
        dateCompleted: Date = Date.distantPast,
        summary: String = "",
        rating: Int? = nil,
        status: Status = .onShelf
    ) {
        self.title = title
        self.author = author
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.summary = summary
        self.rating = rating
        self.status = status
    }
    
    // 计算属性；不改变模型结构
    var icon: Image {
        switch status {
        case .onShelf:
            Image(systemName: "checkmark.diamond.fill")
        case .inProgress:
            Image(systemName: "book.fill")
        case .completed:
            Image(systemName: "books.vertical.fill")
        }
    }
}


// Swift 中的枚举可以具有「原始值」，比如 Int、String、Double 等。如果你写成 enum Status: Int，那每个 case 默认会从 0 开始自增
enum Status: Int, Codable, Identifiable, CaseIterable {
    case onShelf, inProgress, completed
    var id: Self {
        self
    }
    var descr: String {
        switch self {
        case .onShelf:
            "On Shelf"
        case .inProgress:
            "In Progress"
        case .completed:
            "Completed"
        }
        
    }
}
