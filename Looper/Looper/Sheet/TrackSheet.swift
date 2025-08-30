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
                        playTrimmedAudio()
                }
                Button("Save Trimmed") {
                    exportTrimmedAudio()
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
    
    // MARK: - Load Audio
    private func loadAudio() {
        guard let url = trackURL else { return }
        audioAsset = AVAsset(url: url)
        duration = audioAsset?.duration.seconds ?? 0
        endTime = duration
    }
    
    // MARK: - Play Trimmed
    public func playTrimmedAudio() {
        guard let url = trackURL else { return }
        
        let asset = AVAsset(url: url)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("trimmed.m4a")
        try? FileManager.default.removeItem(at: tempURL)
        
        exporter.outputURL = tempURL
        exporter.outputFileType = .m4a
        let startCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCM = CMTime(seconds: endTime, preferredTimescale: 600)
        exporter.timeRange = CMTimeRange(start: startCM, end: endCM)
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                DispatchQueue.main.async {
                    do {
                        player = try AVAudioPlayer(contentsOf: tempURL)
                        player?.numberOfLoops = -1
                        player?.play()
                        playing = true
                    } catch {
                        print("Playback failed: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Save Trimmed
    public func exportTrimmedAudio() {
        guard let url = trackURL else { return }
        
        let asset = AVAsset(url: url)
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
        
        let outputURL = url.deletingPathExtension().appendingPathExtension("trimmed.m4a")
        try? FileManager.default.removeItem(at: outputURL)
        
        let startCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCM = CMTime(seconds: endTime, preferredTimescale: 600)
        exporter.timeRange = CMTimeRange(start: startCM, end: endCM)
        exporter.outputURL = outputURL
        exporter.outputFileType = .m4a
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                DispatchQueue.main.async {
                    print("Saved trimmed audio to \(outputURL)")
                    trackURL = outputURL // replace old file with new trimmed one
                }
            } else {
                print("Export failed: \(exporter.error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
