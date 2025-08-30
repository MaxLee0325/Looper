//
//  AudioTrimmer.swift
//  Looper
//
//  Created by Max Lee on 2025-08-29.
//
import Foundation
import AVFoundation

public class AudioTrimmer: ObservableObject {
    
    private var audioAsset: AVAsset?
    private var player: AVAudioPlayer?
    private var duration: TimeInterval = 0
    
    
    
    
    
    // MARK: - Load Audio
    private func loadAudio(_ trackURL: URL?) {
        guard let url = trackURL else { return }
        audioAsset = AVAsset(url: url)
        duration = audioAsset?.duration.seconds ?? 0
        //endTime = duration
    }
    
    // MARK: - Play Trimmed
    private func playTrimmedAudio(_ trackURL: URL?, _ startTime: Double, _ endTime: Double) {
        
        let exporter = setUpExporter(trackURL)
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("trimmed.m4a")
        try? FileManager.default.removeItem(at: tempURL)
        
        exporter?.outputURL = tempURL
        exporter?.outputFileType = .m4a
        let startCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCM = CMTime(seconds: endTime, preferredTimescale: 600)
        exporter?.timeRange = CMTimeRange(start: startCM, end: endCM)
        
        exporter?.exportAsynchronously {
            if exporter?.status == .completed {
                DispatchQueue.main.async {
                    do {
                        self.player = try AVAudioPlayer(contentsOf: tempURL)
                        self.player?.numberOfLoops = -1
                        self.player?.play()
                    } catch {
                        print("Playback failed: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Save Trimmed
    private func exportTrimmedAudio(_ trackURL: URL?, _ startTime: Double, _ endTime: Double) -> URL{
        
        let exporter = setUpExporter(trackURL)
        
        let outputURL = trackURL!.deletingPathExtension().appendingPathExtension("trimmed.m4a")
        try? FileManager.default.removeItem(at: outputURL)
        
        let startCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCM = CMTime(seconds: endTime, preferredTimescale: 600)
        exporter?.timeRange = CMTimeRange(start: startCM, end: endCM)
        exporter?.outputURL = outputURL
        exporter?.outputFileType = .m4a
        
        exporter?.exportAsynchronously {
            if exporter?.status == .completed {
                DispatchQueue.main.async {
                    print("Saved trimmed audio to \(outputURL)")
                }
            } else {
                print("Export failed: \(exporter?.error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        return outputURL
    }
    
    private func setUpExporter(_ trackURL: URL?) -> AVAssetExportSession? {
        let url = trackURL
        let asset = AVAsset(url: url!)
        return AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
    }
}
