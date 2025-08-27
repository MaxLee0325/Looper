//
//  ProjectView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//
import SwiftUI
import AVFoundation
import SwiftData

enum TrackStatus: Int {
    case idle = 0
    case recording = 1
    case playing = 2
}

struct AudioTrackView: View {
    @Bindable var track: Track
    @State private var status: TrackStatus = .idle
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var recordingURL: URL?
    @State private var showTrackSheet: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    let recordingSession: AVAudioSession
    @State private var recorder: Recorder?

    var body: some View {
        VStack {
            Button(action: {
                if status == .playing {
                    //TODO
                } else if status == .recording {
                    stopRecording()
                } else if status == .idle {
                    startRecording()
                }
            }) {
                Image("idle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(1.0)
                    .rotationEffect(.degrees(status == .recording ? rotation : 0))
                    .scaleEffect(scale)
            }
        }
        .onChange(of: status) {
            if status == .recording {
                recordingAnimation()
            } else if status == .playing{
                playingAnimation()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background || scenePhase == .inactive {
                if status == .recording {
                    stopRecording()
                    if let url = recordingURL {
                        try? FileManager.default.removeItem(at: url)
                    }
                }
                recorder?.audioPlayer?.stop()
            }
        }
        .onAppear(){
            recorder = Recorder(recordingSession)
            
            if let url = track.url {
                recorder?.playAudio(from: url)
                status = .playing
            }
        }
        .onDisappear {
            if status == .recording{
                stopRecording()
                if let url = recordingURL {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            recorder?.audioPlayer?.stop()
        }
    }
    
    func startRecording() {
        recorder?.startRecording()
        status = .recording
        track.url = recorder?.getURL()
    }
    
    func stopRecording() {
        recorder?.stopRecording()
        status = .playing
        
        if let url = recordingURL {
            recorder?.playAudio(from: url)
        }
    }
    
    func recordingAnimation() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        scale = 1.0
    }
    
    func playingAnimation() {
        withAnimation(.easeInOut(duration: 0.1)) {
            rotation = 0
        }
        withAnimation(Animation.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
            scale = 1.1
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Track.self, configurations: config)

    let project = Project(name: "Preview Project", id: UUID())
    let track = Track(id: UUID())
    project.tracks.append(track)

    return AudioTrackView(
        track: track,
        recordingSession: AVAudioSession.sharedInstance()
    )
    .modelContainer(container)
}

