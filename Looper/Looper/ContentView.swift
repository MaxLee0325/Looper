//
//  ContentView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                NavigationLink("Go to Page 2", destination: AudioTrackView())
            }
            .padding()
            .navigationTitle(Text("Home"))
        }
    }
}

#Preview {
    ContentView()
}
