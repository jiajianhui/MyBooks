//
//  ContentView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/5/31.
//

import SwiftUI
import SwiftData

// 筛选
enum SortOrder: LocalizedStringResource, Identifiable, CaseIterable {
    case status, title, author
    
    var id: Self {
        self
    }
}



struct BookListView: View {
    
    // 弹窗状态
    @State private var createNewBook = false
    
    // sort
    @State private var sortOrder = SortOrder.status
    
    // search
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            
            // 筛选picker
            Picker("", selection: $sortOrder) {
                ForEach(SortOrder.allCases) { sortOrder in
                    Text("sort by \(sortOrder.rawValue)")
                }
            }
            
            // 数据列表
            QueryBookListView(searchText: searchText, sortOrder: sortOrder)
            
            .navigationTitle("My Books")
            .toolbar {
                Button {
                    createNewBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
            
            .sheet(isPresented: $createNewBook) {
                NewBookView()
                    .presentationDragIndicator(.visible)
            }
            
            // 搜索框
            .searchable(text: $searchText, prompt: Text("Search title or author"))
        }
        
    }
}

#Preview("English") {
    BookListView()
        .modelContainer(for: Book.self, inMemory: true)
}

#Preview("Chinese") {
    BookListView()
        .modelContainer(for: Book.self, inMemory: true)
        .environment(\.locale, Locale(identifier: "Zh"))
}
