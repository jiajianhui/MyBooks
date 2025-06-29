//
//  GenreStackView.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/6/29.
//

import SwiftUI

struct GenreStackView: View {
    let genres: [Genre]
    var body: some View {
        HStack {
            ForEach(genres) { genre in
                Text(genre.name)
                    .foregroundStyle(Color.white)
                    .font(.callout)
                    .padding(6)
                    .padding(.horizontal, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(genre.hexColor)
                    }
            }
        }
    }
}

//#Preview {
//    GenreStackView()
//}
