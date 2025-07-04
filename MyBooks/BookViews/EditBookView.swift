//
//  EditBookView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/2.
//

import SwiftUI
import PhotosUI

struct EditBookView: View {
    
    let book: Book
    
    // 为模型中的每个属性创建变量
    // 不直接使用Book的数据，更灵活的控制数据（如果表单直接与模型绑定，在输入过程中就会进行数据的更新，这不是我想要的）
    @State private var status = Status.onShelf
    @State private var rating: Int?
    @State private var title = ""
    @State private var author = ""
    @State private var synopsis = ""
    @State private var dateAdded = Date.distantPast
    @State private var dateStarted = Date.distantPast
    @State private var dateCompleted = Date.distantPast
    @State private var recommendedBy = ""
    
    // 避免因为appear中的赋值操作而触发onChange函数
    @State private var firstView = true
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // genre
    @State private var showGenre = false
    
    // 图片相关
    @State private var selectedBookCover: PhotosPickerItem?
    @State private var selectedBookCoverData: Data?
    
    var body: some View {
        HStack {
            Text("Status")
            Picker("status", selection: $status) {
                ForEach(Status.allCases) { status in
                    Text(status.descr)
                }
            }
        }
        
        VStack(alignment: .leading) {
            GroupBox {
                LabeledContent {
                    DatePicker("", selection: $dateAdded, displayedComponents: .date)
                } label: {
                    Text("Date Added")
                }
                
                // Date Started 在进行中或者已完成中都会显示
                if status == .inProgress || status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateStarted, in: dateAdded..., displayedComponents: .date)
                    } label: {
                        Text("Date Started")
                    }
                }
                
                if status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateCompleted, in: dateStarted..., displayedComponents: .date)
                    } label: {
                        Text("Date Completed")
                    }
                }

            }
            .foregroundStyle(.secondary)
            
            // 监听切换状态
            .onChange(of: status) { oldValue, newValue in
                
                if !firstView {
                    if newValue == .onShelf {
                        
                        // 放回书架（不管是从进行中还是完成），重置所有日期
                        dateStarted = Date.distantPast
                        dateCompleted = Date.distantPast
                    } else if newValue == .inProgress && oldValue == .completed {
                        // 从完成到进行中
                        dateCompleted = Date.distantPast
                    } else if newValue == .inProgress && oldValue == .onShelf {
                        // 从书架到进行中
                        dateStarted = Date.now
                    } else if newValue == .completed && oldValue == .onShelf {
                        // 从书架直接完成；因为开始时间还没有，所以将添加时间给到开始时间，保证数据合理、完整
                        dateStarted = dateAdded
                        dateCompleted = Date.now
                    } else if newValue == .completed && oldValue == .inProgress {
                        // 从进行中到完成
                        dateCompleted = Date.now
                    } else {
                        print("⚠️ 未处理的状态变更：\(oldValue) → \(newValue)")
                    }
                    
                }
            }
            
            Divider()
            HStack {
                PhotosPicker(selection: $selectedBookCover, matching: .images, photoLibrary: .shared()) {
                    Group {
                        if let selectedBookCoverData,
                           let uiImage = UIImage(data: selectedBookCoverData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(width: 100)
                    .overlay(alignment: .topTrailing) {
                        if selectedBookCoverData != nil {
                            Button {
                                selectedBookCover = nil
                                selectedBookCoverData = nil
                            } label: {
                                Image(systemName: "x.circle.fill")
                                    .foregroundStyle(Color.red)
                            }
                        }
                    }
                }
                
                VStack {
                    LabeledContent {
                        RatingsView(maxRating: 5, currentRating: $rating, width: 34)
                    } label: {
                        Text("Ratting")
                    }
                    LabeledContent {
                        TextField("", text: $title)
                    } label: {
                        Text("Title")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent {
                        TextField("", text: $author)
                    } label: {
                        Text("Author")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            LabeledContent {
                TextField("", text: $recommendedBy)
            } label: {
                Text("RecommendedBy")
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            Text("Synopsis")
                .foregroundStyle(.secondary)
            TextEditor(text: $synopsis)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 1)
                        
                }
            
            // 标签
            if let genres = book.genres {
                // 自适应滚动，标签过多时是滚动时图，反之为静态视图
                ViewThatFits {
                    GenreStackView(genres: genres)
                    ScrollView(.horizontal, showsIndicators: false) {
                        GenreStackView(genres: genres)
                    }
                }
            }
            
            // quote genre
            HStack {
                
                Button("Genre", systemImage: "bookmark.fill") {
                    showGenre.toggle()
                }
                .sheet(isPresented: $showGenre) {
                    GenresListView(book: book)
                        .presentationDragIndicator(.visible)
                }
                
                NavigationLink {
                    QuotesListView(book: book)
                } label: {
                    let count = book.quotes?.count ?? 0
                    Label("\(count) Quotes", systemImage: "quote.opening")
                }
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .trailing)

        }
        .padding()
        .textFieldStyle(.roundedBorder)
        
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    book.title = title
                    book.author = author
                    book.synopsis = synopsis
                    book.rating = rating
                    book.status = status.rawValue
                    book.dateAdded = dateAdded
                    book.dateStarted = dateStarted
                    book.dateCompleted = dateCompleted
                    book.recommendedBy = recommendedBy
                    book.bookCover = selectedBookCoverData
                    
                    // save
                    try? context.save()
                    
                    dismiss()
                } label: {
                    Text("Update")
                }
                .disabled(!changed)
            }
            
        }
        
        // 页面出现时，将模型数据赋值给我们的变量
        .onAppear {
            title = book.title
            author = book.author
            synopsis = book.synopsis
            rating = book.rating
            status = Status(rawValue: book.status)!
            dateAdded = book.dateAdded
            dateStarted = book.dateStarted
            dateCompleted = book.dateCompleted
            recommendedBy = book.recommendedBy
            selectedBookCoverData = book.bookCover
            
            /*
             关于 @State 的异步更新
             @State 的更新（比如 status = ...）并不是立刻同步生效的，而是在下一轮 RunLoop 的刷新周期中再应用更新。即使 UI 还没更新完成，.onChange(of:) 也可能已经触发了
             在 SwiftUI 中，.onChange(of:) 是通过监听绑定变量（比如 @State 或 @Binding）的变化来触发的。而这个“变化”并不依赖 UI 是否完成渲染
             */
            
            
            /*
             异步导致的changed异常
             onAppear完成status赋值——status绑定在Picker上——触发onChange（不管之前是不是 .now，都赋一次新值，这会改变 @State 的值）——触发 @State 的变化， 进而导致changed变化
             */
            
            
            /*
             使用DispatchQueue后的执行逻辑
             1、页面第一次加载时，firstView == true，即使 SwiftUI 自动触发了 .onChange(of: status)，你也不会做任何操作。
             2、然后，在下一次主线程循环时，将 firstView 设为 false。
             3、用户后续主动更改状态才会进入 .onChange，这时再执行 dateStarted = .now 就完全没问题了。
             */
            
            // 延迟到 UI 完全更新后再设为 false
            DispatchQueue.main.async {
                firstView = false
            }
        }
        
        // 图片数据转换
        .task(id: selectedBookCover) {
            if let data = try? await selectedBookCover?.loadTransferable(type: Data.self) {
                selectedBookCoverData = data
            }
        }
    }
    
    // 数据是否更改
    var changed: Bool {
        title != book.title
        || author != book.author
        || synopsis != book.synopsis
        || rating != book.rating
        || status != Status(rawValue: book.status)!
        || dateAdded != book.dateAdded
        || dateStarted != book.dateStarted
        || dateCompleted != book.dateCompleted
        || recommendedBy != book.recommendedBy
        || selectedBookCoverData != book.bookCover
    }
}

//#Preview {
//    NavigationStack {
//        EditBookView()
//    }
//}
