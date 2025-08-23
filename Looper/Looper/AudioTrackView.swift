//
//  ProjectView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//
import SwiftUI
import AVFoundation

struct AudioTrackView: View {
    @State private var isRecording = false
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var playing = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    @State private var audioPlayer: AVAudioPlayer?
    let trackID: Int
    let recordingSession: AVAudioSession
    
    var body: some View {
        VStack {
            Button(action: {
                if playing {
                    //TODO
                } else if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image("idle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(1.0)
                    .rotationEffect(.degrees(isRecording ? rotation : 0))
                    .scaleEffect(scale)
            }
        }
        .onChange(of: isRecording) {
            if isRecording {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                scale = 1.0
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    rotation = 0
                }
                withAnimation(Animation.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
        }
    }
    
    func startRecording() {
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
            isRecording = true
        } catch {
            print("Fail to start recording: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        playing = true
        
        if let url = recordingURL {
            playAudio(from: url)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func playAudio(from url: URL){
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

#Preview {
    AudioTrackView(trackID: 1, recordingSession: AVAudioSession.sharedInstance())
}
