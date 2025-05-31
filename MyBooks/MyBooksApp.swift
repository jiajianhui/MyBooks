//
//  MyBooksApp.swift
//  MyBooks
//
//  Created by 贾建辉 on 2025/5/31.
//

import SwiftUI
import SwiftData

@main
struct MyBooksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 指定容器，管理数据
        .modelContainer(for: Book.self)
    }
    
    
    // 查看本地数据库的路径
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
