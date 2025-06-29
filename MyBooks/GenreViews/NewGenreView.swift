//
//  NewGenreView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/29.
//

import SwiftUI

struct NewGenreView: View {
    
    @State private var name: String = ""
    @State private var color: Color = .blue
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("name", text: $name)
                ColorPicker("set the genre color", selection: $color, supportsOpacity: false)
                
                Button("Create") {
                    let newGenre = Genre(name: name, color: color.toHexString()!)
                    context.insert(newGenre)
                    try? context.save()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .navigationTitle("New Genre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewGenreView()
}
