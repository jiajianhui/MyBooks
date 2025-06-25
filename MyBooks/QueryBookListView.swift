//
//  QueryBookListView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/15.
//

import SwiftUI
import SwiftData

struct QueryBookListView: View {
    
    @Environment(\.modelContext) private var context
    
    // 数据库查询——按添加日期、降序排序
    @Query private var books: [Book]
    
    // 初始化
    init(searchText: String, sortOrder: SortOrder) {
        
        // 排序规则构建（默认升序排序）
        let sortDescriptors: [SortDescriptor<Book>] = switch sortOrder {
            case .status:
                // 若status 值相同，则次级排序用 title 字段排序。
                [SortDescriptor(\Book.status), SortDescriptor(\Book.title)]
            case .title:
                [SortDescriptor(\Book.title)]
            case .author:
                [SortDescriptor(\Book.author)]
        }
        
        // 谓词过滤器（搜索）
        let predicate = #Predicate<Book> { book in
            book.title.localizedStandardContains(searchText) ||
            book.author.localizedStandardContains(searchText) ||
            searchText.isEmpty // 如果搜索框为空，就不过滤，显示全部
        }
        
        // 动态创建一个带排序、搜索的查询实例；为 @Query private var books 提供自定义查询配置
        _books = Query(filter: predicate, sort: sortDescriptors)
        
        // 查看视图是否被重建
        print("📦 View Rebuilt: sortOrder = \(sortOrder)")
    }
    
    var body: some View {
        Group {
            if books.isEmpty {
                ContentUnavailableView("Enter your first book.", systemImage: "book.fill")
            } else {
                List {
                    ForEach(books) { book in
                        NavigationLink {
                            EditBookView(book: book)
                        } label: {
                            HStack(spacing: 10) {
                                book.icon
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.title2)
                                    Text(book.author)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    if let rating = book.rating {
                                        HStack {
                                            ForEach(1..<rating, id: \.self) { _ in
                                                Image(systemName: "star.fill")
                                                    .imageScale(.small)
                                                    .foregroundStyle(Color.yellow)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    // indexSet是数组元素的索引集合
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let book = books[index]
                            context.delete(book)
                        }
                        
                        try? context.save()
                    }
                }
                .listStyle(.plain)

            }
        }
    }
}

//#Preview {
//    QueryBookListView()
//}
