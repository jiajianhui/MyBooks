//
//  ContentView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/5/31.
//

import SwiftUI
import SwiftData

struct BookListView: View {
    
    // 弹窗状态
    @State private var createNewBook = false
    
    // 数据库查询
    @Query(sort: \Book.title) private var books: [Book]
    
    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    ContentUnavailableView("Enter your first book.", systemImage: "book.fill")
                } else {
                    List {
                        ForEach(books) { book in
                            NavigationLink {
                                Text(book.title)
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
                                                ForEach(0..<rating, id: \.self) { _ in
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
                    }
                    .listStyle(.plain)
                }
            }
            
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
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        
    }
}

#Preview {
    BookListView()
        .modelContainer(for: Book.self, inMemory: true)
}
