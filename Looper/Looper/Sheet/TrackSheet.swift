//
//  TrackSheet.swift
//  Looper
//
//  Created by Max Lee on 2025-08-26.
//

import SwiftUI
import AVFoundation

struct TrackSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var trackURL: URL?
    @Binding var bpm: Double
    
    @State private var audioAsset: AVAsset?
    @State private var player: AVAudioPlayer?
    @State private var playing: Bool = false
    
    // Trimming state
    @State private var startTime: Double = 0
    @State private var endTime: Double = 0
    @State private var duration: Double = 0
    
    @State private var audioTrimmer: AudioTrimmer?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("BPM: \(Int(bpm))")
                .font(.headline)
            
            if let duration = audioAsset?.duration.seconds {
                Text("Audio Length: \(String(format: "%.2f", duration))s")
            }
            
            // Waveform display
            if let url = trackURL {
                // Range slider for trimming
                if duration > 0 {
                    VStack {
                        RangeSlider(start: $startTime, end: $endTime, url: url, maxValue: duration)
                        
                        Text("Start: \(String(format: "%.2f", startTime))s | End: \(String(format: "%.2f", endTime))s")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Playback preview
            HStack {
                Button("Play Trimmed") {
                    if playing {
                        player?.stop()
                    }
                    audioTrimmer?.playTrimmedAudio(trackURL, startTime, endTime)
                }
                Button("Save Trimmed") {
                    trackURL = audioTrimmer?.exportTrimmedAudio(trackURL, startTime, endTime)
                }
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
        }
        .padding()
        .onAppear {
            loadAudio()
            audioTrimmer = AudioTrimmer()
        }
    }
    
    private func loadAudio() {
        guard let url = trackURL else { return }
        audioAsset = AVAsset(url: url)
        duration = audioAsset?.duration.seconds ?? 0
        endTime = duration
    }

}
