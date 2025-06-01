//
//  NewBookView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/5/31.
//

import SwiftUI

struct NewBookView: View {
    
    @State private var title = ""
    @State private var author = ""
    
    @Environment(\.dismiss) var dismiss
    
    // 从环境中拿到容器的context，来处理数据的增删改查
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                
                Button {
                    // 1、准备新数据
                    let newBook = Book(title: title, author: author)
                    // 2、C——插入数据库
                    context.insert(newBook)
                    // 3、关闭弹窗
                    dismiss()
                } label: {
                    Text("Create")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(title.isEmpty || author.isEmpty)
                
                .navigationTitle("New Book")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss() 
                        }
                    }
                }

            }
        }
    }
}

#Preview {
    NewBookView()
}
