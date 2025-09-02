//
//  TempoSheet.swift
//  Looper
//
//  Created by Max Lee on 2025-08-25.
//

import SwiftUI
import Foundation

struct TempoSheet: View {
    @Binding var tempo: Double
    @Environment(\.dismiss) var dismiss
    @Binding var introBeats: Double
    
    @State private var metronome: Metronome?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Tempo")
                .font(.headline)
            
            Slider(value: $tempo, in: 40...240, step: 1) {
                Text("Tempo")
            }
            .padding()
            
            Text("\(Int(tempo)) BPM")
                .font(.title2)
                .foregroundColor(.blue)
            .padding()

            Slider(value: $introBeats, in: 0...30, step: 1) {
                Text("Intro Beats")
            }
            
            Text("Start Recording After: \(Int(introBeats)) Beats")
                .font(.title2)
                .foregroundColor(.blue)
            .padding()
            
            Button("Done") {
                metronome?.stop()
                dismiss()
            }
            .padding()
        }
        .padding()
        .onAppear() {
            metronome = Metronome(tempo)
            metronome?.start()
        }
        .onChange(of: tempo) {
            metronome?.stop()
            metronome?.setBPM(tempo)
        }
        .onDisappear {
            metronome?.isRunning = false
            metronome?.stop()
        }
    }
    

}


