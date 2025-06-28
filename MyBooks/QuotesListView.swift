//
//  QuotesListView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/27.
//

import SwiftUI

struct QuotesListView: View {
    
    @Environment(\.modelContext) private var context
    
    @State var page: String = ""
    @State var text: String = ""
    
    @State var selectedQuote: Quote?
    var isEditing: Bool {
        selectedQuote != nil
    }
    
    let book: Book
    
    
    var body: some View {
        GroupBox {
            // page
            HStack {
                LabeledContent("Page") {
                    TextField("Page #", text: $page)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 130)
                    Spacer()
                    
                    
                    if isEditing {
                        Button("Cancel") {
                            page = ""
                            text = ""
                            selectedQuote = nil
                        }
                    }
                    
                    
                    Button(isEditing ? "Update" : "Create") {
                        if isEditing {
                            selectedQuote?.text = text
                            selectedQuote?.page = page.isEmpty ? nil : page
                            
                            try? context.save()
                            
                            page = ""
                            text = ""
                            selectedQuote = nil
                            
                        } else {
                            let quote = page.isEmpty ? Quote(text: text) : Quote(text: text, page: page)
                            book.quotes?.append(quote)
                            
                            try? context.save()
                            
                            page = ""
                            text = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(text.isEmpty)
                }
            }
            
            // text
            TextEditor(text: $text)
                .border(Color.gray.opacity(0.3))
                .frame(height: 200)
        }
        .padding(.horizontal)
        
        // list
        List {
            let sortedQuotes = book.quotes?.sorted(using: KeyPathComparator(\Quote.creationDate)) ?? []
            
            ForEach(sortedQuotes) { quote in
                VStack(alignment:.leading) {
                    
                    HStack {
                        Text(quote.text)
                        Spacer()
                        if let page = quote.page, !page.isEmpty {
                            Text("Page: \(page)")
                                .font(.footnote)
                        }
                    }
                    Text(quote.creationDate, format: .dateTime.month().day().year())
                        .font(.caption)
                        .opacity(0.5)
                }
                .background(content: {
                    // 方便点击
                    Color.white.opacity(0.0001)
                })
                
                // 更新编辑
                .onTapGesture {
                    selectedQuote = quote
                    text = quote.text
                    page = quote.page ?? ""
                }
            }
            // 删除
            .onDelete { indexSet in
                indexSet.forEach { index in
                    if let quote = book.quotes?[index] {
                        context.delete(quote)
                        try?context.save()
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Quotes")
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}

#Preview {
    QuotesListView(book: Book(title: "hello", author: "world"))
}
