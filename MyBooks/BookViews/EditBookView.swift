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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @StateObject private var vm: EditBookViewModel
    
    
    // 初始化；在性能上会有提升，例如显示导航标题时，不会有延迟
    init(book: Book) {
        self.book = book
        
        // SwiftUI 的语法约定——初始化 @StateObject 时，要使用下划线前缀
        _vm = StateObject(wrappedValue: EditBookViewModel(book: book))
    }
    
    // genre
    @State private var showGenre = false
    
    var body: some View {
        VStack(alignment: .leading) {
            StatusSection(vm: vm)
            DateSection(vm: vm)
            
            Divider()
            HStack {
                PhotoSection(vm: vm)
                BookSection(vm: vm)
            }
            
            RecomSection(vm: vm)
            Divider()
            SynoSection(vm: vm)
            
            // 标签
            GenreSection(book: book)
            
            // quote genre
            ButtonSection(showGenre: $showGenre, book: book)

        }
        .padding()
        .textFieldStyle(.roundedBorder)
        
        .navigationTitle(vm.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    vm.update(book)
                    // save
                    try? context.save()
                    
                    dismiss()
                } label: {
                    Text("Update")
                }
                .disabled(!vm.isChanged(book))
            }
            
        }
        
        // 页面出现时，将模型数据赋值给我们的变量
        .onAppear {
            vm.onAppear(from: book)
        }
        
        // 图片数据转换
        .task(id: vm.selectedBookCover) {
            await vm.loadCoverData()
        }
    }
    
}

//#Preview {
//    NavigationStack {
//        EditBookView()
//    }
//}



//MARK: -- 组件模块


// 状态选择模块
struct StatusSection: View {
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        HStack {
            Text("Status")
            Picker("status", selection: $vm.status) {
                ForEach(Status.allCases) { status in
                    Text(status.descr)
                }
            }
        }
    }
}


// 日期显示模块
struct DateSection: View {
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        GroupBox {
            LabeledContent {
                DatePicker("", selection: $vm.dateAdded, displayedComponents: .date)
            } label: {
                Text("Date Added")
            }
            
            // Date Started 在进行中或者已完成中都会显示
            if vm.status == .inProgress || vm.status == .completed {
                LabeledContent {
                    DatePicker("", selection: $vm.dateStarted, in: vm.dateAdded..., displayedComponents: .date)
                } label: {
                    Text("Date Started")
                }
            }
            
            if vm.status == .completed {
                LabeledContent {
                    DatePicker("", selection: $vm.dateCompleted, in: vm.dateStarted..., displayedComponents: .date)
                } label: {
                    Text("Date Completed")
                }
            }

        }
        .foregroundStyle(.secondary)
        
        // 监听切换状态
        .onChange(of: vm.status) { oldValue, newValue in
            vm.changeStatus(from: oldValue, to: newValue)
        }
    }
}


// 图片选择模块
struct PhotoSection: View {
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        PhotosPicker(selection: $vm.selectedBookCover, matching: .images, photoLibrary: .shared()) {
            Group {
                if let data = vm.selectedBookCoverData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            .overlay(alignment: .topTrailing) {
                if vm.selectedBookCoverData != nil {
                    Button {
                        vm.removeCover()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color.red)
                    }
                }
            }
        }
    }
}


// 书籍信息模块
struct BookSection: View {
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        VStack {
            LabeledContent {
                RatingsView(maxRating: 5, currentRating: $vm.rating, width: 34)
            } label: {
                Text("Ratting")
            }
            LabeledContent {
                TextField("", text: $vm.title)
            } label: {
                Text("Title")
                    .foregroundStyle(.secondary)
            }
            LabeledContent {
                TextField("", text: $vm.author)
            } label: {
                Text("Author")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// 推荐模块
struct RecomSection: View {
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        LabeledContent {
            TextField("", text: $vm.recommendedBy)
        } label: {
            Text("RecommendedBy")
                .foregroundStyle(.secondary)
        }
    }
}

// 总结模块
struct SynoSection: View {
    
    @ObservedObject var vm: EditBookViewModel
    
    var body: some View {
        Text("Synopsis")
            .foregroundStyle(.secondary)
        TextEditor(text: $vm.synopsis)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 1)
                    
            }
    }
}

// 标签模块
struct GenreSection: View {
    
    let book: Book
    
    var body: some View {
        if let genres = book.genres {
            // 自适应滚动，标签过多时是滚动时图，反之为静态视图
            ViewThatFits {
                GenreStackView(genres: genres)
                ScrollView(.horizontal, showsIndicators: false) {
                    GenreStackView(genres: genres)
                }
            }
        }
    }
}


// 新建标签、摘录按钮
struct ButtonSection: View {
    
    @Binding var showGenre: Bool
    let book: Book
    
    var body: some View {
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
        .padding()
    }
}


