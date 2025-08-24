//
//  Looper.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import SwiftUI
import AVFoundation
import SwiftData

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    @State private var tracks: [Int] = [1]
    @State private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    @State private var isAlertPresented: Bool = false
    @Bindable var project: Project
    
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
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

#Preview {
    // Create a mock project for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, configurations: config)
    let project = Project(name: "Preview Project", id: UUID())
    return ProjectView(project: project)
        .modelContainer(container)
}

