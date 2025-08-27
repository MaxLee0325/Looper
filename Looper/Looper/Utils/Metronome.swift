//
//  Metronome.swift
//  Looper
//
//  Created by Max Lee on 2025-08-25.
//

import Foundation
import AVFoundation

class Metronome: ObservableObject {
    @Published var currentBeat = 0  // for UI sync
    
    public var bpm: Double
    public var beatsPerBar: Int
    
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var tickBuffer: AVAudioPCMBuffer?
    private var tockBuffer: AVAudioPCMBuffer? // accent
    private var isRunning = false
    
    //TODO: beats per bar can be used in future work
    init(bpm: Double, beatsPerBar: Int = 4) {
        self.bpm = bpm
        self.beatsPerBar = beatsPerBar
        setUpAudio()
    }
    
    private func loadBuffer(named name: String) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else { return nil }
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else { return nil }
        
        try? file.read(into: buffer)
        return buffer
    }
    
    private func setUpAudio() {
        tickBuffer = loadBuffer(named: "metronome")
        tockBuffer = loadBuffer(named: "metronome")
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: tickBuffer?.format)
        
        do {
            try engine.start()
        } catch {
            print("⚠️ Engine failed: \(error)")
        }
    }
    
    func start() {
        guard let tick = tickBuffer, let tock = tockBuffer else { return }
        
        let sampleRate = tick.format.sampleRate
        let samplesPerBeat = AVAudioFramePosition((60.0 / bpm) * sampleRate)
        
        var nextBeatTime = AVAudioTime(sampleTime: 0, atRate: sampleRate)
        var beatInBar = 0
        
        isRunning = true
        currentBeat = 0
        playerNode.play()
        
        scheduleBeat()
        
        func scheduleBeat() {
            if !isRunning { return }
            
            let buffer = (beatInBar == 0) ? tock : tick // accent on beat 1
            playerNode.scheduleBuffer(buffer, at: nextBeatTime, options: []) {
                beatInBar = (beatInBar + 1) % self.beatsPerBar
                self.currentBeat = beatInBar + 1 // update UI (1–beatsPerBar)
                
                nextBeatTime = AVAudioTime(
                    sampleTime: nextBeatTime.sampleTime + samplesPerBeat,
                    atRate: sampleRate
                )
                scheduleBeat()
            }
        }
    }
    
    func stop() {
        isRunning = false
        playerNode.stop()
        playerNode.reset()
    }
    
    func setBPM(_ bpm: Double) {
        self.bpm = bpm
        stop()
        start()
    }
}




