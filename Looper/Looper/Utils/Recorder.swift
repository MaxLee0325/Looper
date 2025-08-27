//
//  Recorder.swift
//  Looper
//
//  Created by Max Lee on 2025-08-26.
//

import AVFoundation
import SwiftUICore

public class Recorder: ObservableObject  {
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var audioPlayer: AVAudioPlayer?
    @Environment(\.scenePhase) private var scenePhase
    let recordingSession: AVAudioSession
    
    init(recordingURL: URL, recordingSession: AVAudioSession) {
        self.recordingURL = recordingURL
        self.recordingSession = recordingSession
    }
    
    public func startRecording() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFileName
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: Int(AVAudioQuality.high.rawValue)
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Fail to start recording: \(error.localizedDescription)")
        }
    }
    
    public func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if let url = recordingURL {
            playAudio(from: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public func playAudio(from url: URL){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch{
            print("Fail to play audio: \(error.localizedDescription)")
        }
    }
    
}
