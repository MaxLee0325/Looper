//
//  TempoSheet.swift
//  Looper
//
//  Created by Max Lee on 2025-08-25.
//

import SwiftUI
import Foundation
import AVFoundation

struct TempoSheet: View {
    @Binding var tempo: Double
    @Environment(\.dismiss) var dismiss
    
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
            
            Button("Done") {
                metronome?.stopMetronome()
                dismiss()
            }
            .padding()
        }
        .padding()
        .onAppear() {
            metronome = Metronome(bpm: tempo)
            metronome?.startMetronome(bpm: tempo)
        }
        .onChange(of: tempo) { newValue in
            metronome?.stopMetronome()
            metronome?.startMetronome(bpm: newValue)
        }
        .onDisappear {
            metronome?.stopMetronome()
        }
    }
    

}


