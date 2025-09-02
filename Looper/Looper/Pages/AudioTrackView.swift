//
//  ProjectView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//
import SwiftUI
import AVFoundation
import SwiftData
import SDWebImageSwiftUI

enum TrackStatus: Int {
    case idle = 0
    case recording = 1
    case playing = 2
    case stop = 3
}

struct AudioTrackView: View {
    @Bindable var track: Track
    @State private var status: TrackStatus = .idle
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var showTrackSheet: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    let recordingSession: AVAudioSession
    @State private var recorder: Recorder?
    @State private var metronome: Metronome
    @State private var icon: String = "mic"

    init(track: Track, recordingSession: AVAudioSession) {
        self.track = track
        self.recordingSession = recordingSession
        _metronome = State(initialValue: Metronome(track.bpm))
    }


    var body: some View {
        VStack {
            Button(action: {
                print("Recorded: \(track.recorded)", status)
                if track.recorded {
                    showTrackSheet = true
                } else if status == .recording {
                    stopRecording()
                } else if status == .idle {
                    startRecording()
                }
            }) {
                AnimatedImage(name: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipped()
                    .opacity(1.0)
            }
            .sheet(isPresented: $showTrackSheet) {
                TrackSheet(trackURL: $track.url, bpm: $track.bpm)
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
                    if let url = track.url {
                        try? FileManager.default.removeItem(at: url)
                    }
                }
                recorder?.audioPlayer?.stop()
            }
        }
        .onChange(of: showTrackSheet){
            if showTrackSheet{
                recorder?.stopPlaying()
            } else {
                if let url = track.url {
                    recorder?.playAudio(from: url)
                    status = .playing
                }
            }
        }
        .onChange(of: track.playing){
            track.playing ? playRecording(): stopPlaying()
        }
        .onChange(of: track.bpm){
            metronome.bpm = track.bpm
        }
        .onAppear(){
            recorder = Recorder(recordingSession)
            metronome = Metronome(track.bpm)
            if let url = track.url {
                recorder?.playAudio(from: url)
                status = .playing
            }
        }
        .onDisappear {
            if status == .recording{
                stopRecording()
                if let url = track.url {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            metronome.stop()
        }
        .onReceive(metronome.$currentBeat) { beat in
            if(beat == track.introBeats){
                metronome.mute()
            }
            
            if beat == track.introBeats + 2{
                metronome.stop()
                recorder?.startRecording()
                status = .recording
                track.url = recorder?.getURL()
            }
        }

    }
    
    func startRecording() {
        if(track.introBeats == 0 || track.number != 1) {
            recorder?.startRecording()
            status = .recording
            track.url = recorder?.getURL()
        } else {
            metronome.start()
        }
    }
    
    func stopRecording() {
        recorder?.stopRecording()
        track.recorded = true
        playRecording()
        track.playing = true
    }
    
    func stopPlaying(){
        recorder?.stopPlaying()
        status = .stop
        icon = "Play dvd, disk_freeze"
    }
    
    func playRecording(){
        if let url = track.url {
            recorder?.playAudio(from: url)
            status = .playing
        }
    }
    
    func recordingAnimation() {
        icon = "Mic Animation.gif"
    }
    
    func playingAnimation() {
        icon = "Play dvd, disk.gif"
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

