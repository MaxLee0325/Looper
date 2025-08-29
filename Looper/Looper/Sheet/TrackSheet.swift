//
//  TrackSheet.swift
//  Looper
//
//  Created by Max Lee on 2025-08-26.
//

import SwiftUI
import Foundation

struct TrackSheet: View {
    @State var volume: Float = 0.5
    @Environment(\.dismiss) var dismiss
    @Binding var TrackURL: URL?
    

    var body: some View {
        VStack(spacing: 20) {

        }
        .onAppear() {
        }
        .onDisappear {
        }
    }
    
}
