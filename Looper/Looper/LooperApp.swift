//
//  LooperApp.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import SwiftUI
import SwiftData

@main
struct LooperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Project.self)
    }
}
