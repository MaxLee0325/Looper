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
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var audioBuffer: AVAudioPCMBuffer?
    private var isRunning = false
    
    init(bpm: Double) {
        self.bpm = bpm
        setUpAudio()
    }
    
    private func setUpAudio() {
        guard let url = Bundle.main.url(forResource: "metronome", withExtension: "wav") else {
            print("⚠️ No metronome.wav found in bundle")
            return
        }
        
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            print("⚠️ Could not load tick sound: \(error)")
            return
        }
        
        // Convert to PCM buffer
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else {
            return
        }
        do {
            try file.read(into: buffer)
        } catch {
            print("⚠️ Could not read file into buffer: \(error)")
            return
        }
        audioBuffer = buffer
        
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: buffer.format)
        
        do {
            try engine.start()
        } catch {
            print("⚠️ Audio engine failed to start: \(error)")
        }
    }
    
    func startMetronome(bpm: Double) {
        guard let buffer = audioBuffer else { return }
        
        let interval = 60.0 / bpm
        let sampleRate = buffer.format.sampleRate
        let samplesPerBeat = AVAudioFramePosition(interval * sampleRate)
        
        var nextBeatTime = AVAudioTime(sampleTime: 0, atRate: sampleRate)
        
        isRunning = true
        
        func scheduleNextBeat() {
            if !isRunning { return }
            playerNode.scheduleBuffer(buffer, at: nextBeatTime, options: []) {
                nextBeatTime = AVAudioTime(
                    sampleTime: nextBeatTime.sampleTime + samplesPerBeat,
                    atRate: sampleRate
                )
                scheduleNextBeat()  // recursion → infinite
            }
        }
        
        scheduleNextBeat()
        playerNode.play()
    }
    
    public func stopMetronome() {
        isRunning = false
        playerNode.stop()
        playerNode.reset()
    }
    
    public func setBPM(_ bpm: Double) {
        self.bpm = bpm
        stopMetronome()
        startMetronome(bpm: bpm)
    }
}



