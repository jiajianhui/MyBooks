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
    
    // 修改属性名
    @Attribute(originalName: "summary")
    var synopsis: String
    
    var rating: Int?
    var status: Status.RawValue  // 数据库无法直接比较枚举类型 enum，只能比较基本类型，比如 Int、String。
    
    // 添加新属性
    var recommendedBy: String = ""
    
    // 一对多
    @Relationship(deleteRule: .cascade)  // 删除book时，关联的quote也将被删除
    var quotes: [Quote]?
    
    // 多对多
    @Relationship(inverse: \Genre.book)
    var genres: [Genre]?
    
    // 初始化；title和author为必填项，其它属性设置了默认值
    init(
        title: String,
        author: String,
        dateAdded: Date = Date.now,
        dateStarted: Date = Date.distantPast,  // 通常用于表示“尚未完成”、“默认无效时间”或“初始值”。
        dateCompleted: Date = Date.distantPast,
        summary: String = "",
        rating: Int? = nil,
        status: Status = .onShelf,
        recommendedBy: String = ""
    ) {
        self.title = title
        self.author = author
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.synopsis = summary
        self.rating = rating
        self.status = status.rawValue
        self.recommendedBy = recommendedBy
    }
    
    // 计算属性；不改变模型结构
    var icon: Image {
        switch Status(rawValue: status)! {
        case .onShelf:
            Image(systemName: "books.vertical.fill")
        case .inProgress:
            Image(systemName: "book.fill")
        case .completed:
            Image(systemName: "checkmark.diamond.fill")
        }
    }
}



/**
 Int    每个 case 的底层原始值为 Int（0、1、2）
 Codable    使 Status 可以被编码/解码（用于 JSON 读写等）
 Identifiable    用于 ForEach 等视图中唯一标识（通过 id 实现）
 CaseIterable    自动生成 allCases 属性（表示该枚举中所有的 case，方便遍历）
 */
enum Status: Int, Codable, Identifiable, CaseIterable {
    case onShelf, inProgress, completed
    
    // 这是 Identifiable 协议所要求的 id 属性。它返回自身 self，意思是每个枚举值本身就是唯一标识。
    // 枚举（enum）定义了一组有限的可能值；枚举的实例是这些可能值中的一个具体值。
    var id: Self {  // Self——当前类型（Status）、self——当前实例（比如 .onShelf）
        self
    }
    
    // descr 是一个 自定义的计算属性，用于将每种状态转化为可读文本，适合用在界面中展示
    var descr: LocalizedStringResource {
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
