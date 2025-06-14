//
//  EditBookView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/2.
//

import SwiftUI

struct EditBookView: View {
    
    let book: Book
    
    // 为模型中的每个属性创建变量
    // 不直接使用Book的数据，更灵活的控制数据（如果表单直接与模型绑定，在输入过程中就会进行数据的更新，这不是我想要的）
    @State private var status = Status.onShelf
    @State private var rating: Int?
    @State private var title = ""
    @State private var author = ""
    @State private var summary = ""
    @State private var dateAdded = Date.distantPast
    @State private var dateStarted = Date.distantPast
    @State private var dateCompleted = Date.distantPast
    
    // 避免因为appear中的赋值操作而触发onChange函数
    @State private var firstView = true
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
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
                        DatePicker("", selection: $dateStarted, displayedComponents: .date)
                    } label: {
                        Text("Date Started")
                    }
                }
                
                if status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateCompleted, displayedComponents: .date)
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
            
            Divider()
            Text("Summary")
                .foregroundStyle(.secondary)
            TextEditor(text: $summary)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 1)
                        
                }
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
                    book.summary = summary
                    book.rating = rating
                    book.status = status
                    book.dateAdded = dateAdded
                    book.dateStarted = dateStarted
                    book.dateCompleted = dateCompleted
                    
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
            summary = book.summary
            rating = book.rating
            status = book.status
            dateAdded = book.dateAdded
            dateStarted = book.dateStarted
            dateCompleted = book.dateCompleted
            
            
            firstView = false
        }
    }
    
    // 数据是否更改
    var changed: Bool {
        title != book.title
        || author != book.author
        || summary != book.summary
        || rating != book.rating
        || status != book.status
        || dateAdded != book.dateAdded
        || dateStarted != book.dateStarted
        || dateCompleted != book.dateCompleted
    }
}

#Preview {
    NavigationStack {
//        EditBookView()
    }
}
