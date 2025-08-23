//
//  Looper.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import SwiftUI
import AVFoundation

struct ProjectView: View {
    @State private var tracks: [Int] = [1]
    @State private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    @State private var isAlertPresented: Bool = false
    @State private var recordedFiles: [URL] = []
    
    var body: some View {
        VStack{
            ScrollView{
                VStack(spacing: 20){
                    ForEach(tracks, id: \.self) {trackID in
                        AudioTrackView(trackID: trackID, recordingSession: recordingSession)
                    }
                    .padding()
                }
            }
            
            HStack{
                Button(action:{
                    addTrack()
                }){
                    Text("Add Track")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                
                Button(action:{
                    isAlertPresented = true
                }) {
                    Text("Clear All")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.alert("Are you sure you want to remove all tracks?", isPresented: $isAlertPresented, actions:{
                    Button("Cancel", role: .cancel) {
                        isAlertPresented = false
                    }
                    
                    Button("OK"){
                        clearAll()
                        isAlertPresented = false
                    }
                })
            }
            .padding()
        }
        .task{
            await setupAudioSession()
        }
        
    }
    
    func addTrack(){
        let newTrackID = (tracks.max() ?? 0) + 1
        tracks.append(newTrackID)
    }
    
    func clearAll(){
        
        tracks.removeAll()
    }
    
    func setupAudioSession() async {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        print("Microphone permission denied")
                    }
                }
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProjectView()
}
