//
//  EditBookViewModel.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/7/5.
//

import SwiftUI
import PhotosUI


class EditBookViewModel: ObservableObject {
    
    // 为模型中的每个属性创建变量
    // 不直接使用Book的数据，更灵活的控制数据（如果表单直接与模型绑定，在输入过程中就会进行数据的更新，这不是我想要的）
    @Published var status = Status.onShelf
    @Published var rating: Int?
    @Published var title = ""
    @Published var author = ""
    @Published var synopsis = ""
    @Published var dateAdded = Date.distantPast
    @Published var dateStarted = Date.distantPast
    @Published var dateCompleted = Date.distantPast
    @Published var recommendedBy = ""
    
    // 图片相关
    @Published var selectedBookCover: PhotosPickerItem?
    @Published var selectedBookCoverData: Data?
    
    
    // 初始化
    init(book: Book) {
        onAppear(from: book)
    }
    
    // 避免因为appear中的赋值操作而触发onChange函数
    private var firstView = true
    
    
    func onAppear(from book: Book) {
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
            self.firstView = false
        }
    }
    
    
    // 数据是否更改
    func isChanged(_ book: Book) -> Bool {
        return title != book.title
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
    
    // 更新数据
    func update(_ book: Book) {
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
    }
    
    // 清除图片
    func removeCover() {
        selectedBookCover = nil
        selectedBookCoverData = nil
    }
    
    // 更改状态
    func changeStatus(from oldValue: Status, to newValue: Status) {
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
    
    
    // 图片数据转换
    @MainActor
    func loadCoverData() async{
        if let data = try? await selectedBookCover?.loadTransferable(type: Data.self) {
            selectedBookCoverData = data
        }
    }
}
