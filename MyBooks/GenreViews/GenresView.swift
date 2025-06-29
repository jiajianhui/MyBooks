//
//  GenresView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/29.
//

import SwiftUI
import SwiftData

struct GenresView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var book: Book
    @Query(sort: \Genre.name) var genres: [Genre]
    
    // 新建genre
    @State private var newGenre = false
    
    var body: some View {
        NavigationStack {
            
            // 没有标签时
            if genres.isEmpty {
                ContentUnavailableView {
                    Image(systemName: "bookmark.fill")
                        .font(.largeTitle)
                } description: {
                    Text("you need add some genres first.")
                } actions: {
                    Button("Create Genre") {
                        newGenre.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                // 有书签时
                List {
                    ForEach(genres) { genre in
                        HStack {
                            if let bookGenres = book.genres {
                                if bookGenres.isEmpty {
                                    Button {
                                        addRemove(genre)
                                    } label: {
                                        Image(systemName: "circle")
                                    }
                                    .foregroundStyle(genre.hexColor)

                                } else {
                                    Button {
                                        addRemove(genre)
                                    } label: {
                                        // 如果book包含该标签，就选中
                                        Image(systemName: bookGenres.contains(genre) ? "circle.fill" : "circle")
                                    }
                                    .foregroundStyle(genre.hexColor)
                                }
                            }
                            Text(genre.name)
                            
                        }
                        
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            context.delete(genres[index])
                            try? context.save()
                        }
                    }
                    
                    Button("Create new genre") {
                        newGenre.toggle()
                    }
                }
                
                
            }
        }
        .navigationTitle("Genres")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $newGenre) {
            NewGenreView()
        }
    }
    
    
    // 添加、移除标签的函数
    func addRemove(_ genre: Genre) {
        if let bookGenres = book.genres {
            if bookGenres.isEmpty {
                book.genres?.append(genre)
                try? context.save()
            } else {
                if bookGenres.contains(genre),
                   let index = bookGenres.firstIndex(where: {$0.id == genre.id}) {
                    book.genres?.remove(at: index)
                    try? context.save()
                } else {
                    book.genres?.append(genre)
                    try? context.save()
                }
                    
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        GenresView()
//    }
//}
