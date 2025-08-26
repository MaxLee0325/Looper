//
//  Metronome.swift
//  Looper
//
//  Created by Max Lee on 2025-08-25.
//

import Foundation
import AVFoundation

class Metronome: ObservableObject {
    
    public var bpm: Double
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    init(bpm: Double) {
        self.bpm = bpm
        setUpPlayer()
    }
    
    public func startMetronome(bpm: Double) {
        let interval = 60.0 / bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.player?.play()
        }
    }
    
    private func setUpPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "metronome", withExtension: "wav") else {
            print("⚠️ No metronome.wav found in bundle")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.prepareToPlay()
        } catch {
            print("⚠️ Could not load tick sound: \(error)")
        }
    }
    
    public func setBPM(_ bpm: Double) {
        stopMetronome()
        startMetronome(bpm: bpm)
    }
    
    public func stopMetronome() {
        timer?.invalidate()
        player?.stop()
    }
    
    
    
    
    
    
}


