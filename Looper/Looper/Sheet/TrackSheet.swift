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
    @Binding var tempo: Double
    @Environment(\.dismiss) var dismiss
    @Binding var introBeats: Double
        
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Volume")
                .font(.headline)
            
            Slider(value: $volume, in: 0...100, step: 1) {
                Text("Volume")
            }
            .padding()
            
            Text("Volume: \(Int(volume))")
                .font(.title2)
                .foregroundColor(.blue)
            .padding()

            
            Slider(value: $introBeats, in: 1...30, step: 1) {
                Text("Intro Beats")
            }
            
            Text("Start Recording After: \(Int(introBeats)) Beats")
                .font(.title2)
                .foregroundColor(.blue)
            .padding()
            
            HStack(spacing: 10){
                Button("Back") {
                    dismiss()
                }
                .padding()
                
                Button("Start"){
                }
            }
        }
        .onAppear() {
        }
        .onDisappear {
        }
    }
    
    func StartRecording(){
        dismiss()
    }
}
