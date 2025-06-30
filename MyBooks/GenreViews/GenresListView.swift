//
//  GenresView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/29.
//

import SwiftUI
import SwiftData

struct GenresListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var book: Book
    @Query(sort: \Genre.name) var genres: [Genre]
    
    // 新建genre
    @State private var newGenre = false
    
    var body: some View {
        NavigationStack {
            
            Group {
                // 没有标签时
                if genres.isEmpty {
                    EmptyGenreView(newGenre: $newGenre)
                } else {
                    // 有书签时
                    List {
                        ForEach(genres) { genre in
                            HStack {
                                Button {
                                    addRemove(genre)
                                } label: {
                                    // 如果book包含该标签，就选中；book.genres?.contains(genre)是一个可选Bool，所以要与true进行比较
                                    Image(systemName: book.genres?.contains(genre) == true ? "circle.fill" : "circle")
                                }
                                .foregroundStyle(genre.hexColor)
                                
                                Text(genre.name)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                context.delete(genres[index])
                                try? context.save()
                            }
                        }
                        
                        CreateGenreButton(newGenre: $newGenre)
                    }
                }
            }
            .navigationTitle("Genres")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $newGenre) {
            NewGenreView()
                .presentationDragIndicator(.visible)
        }
    }
    
    
    // 添加、移除标签的函数
    func addRemove(_ genre: Genre) {
        var bookGenres = book.genres ?? []
        
        if let index = bookGenres.firstIndex(where: {$0.id == genre.id}) {
            bookGenres.remove(at: index)
        } else {
            bookGenres.append(genre)
        }
        
        book.genres = bookGenres
        try? context.save()
        
    }
}


// 子视图
struct CreateGenreButton: View {
    @Binding var newGenre: Bool
    
    var body: some View {
        Button("Create new genre") {
            newGenre.toggle()
        }
    }
}

struct EmptyGenreView: View {
    @Binding var newGenre: Bool
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: "bookmark.fill")
                .font(.largeTitle)
        } description: {
            Text("you need add some genres first.")
        } actions: {
            Button("Create new genre") {
                newGenre.toggle()
            }
        }
    }
}



//#Preview {
//    NavigationStack {
//        GenresView()
//    }
//}
