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
    @State private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    @State private var isAlertPresented: Bool = false
    @State private var crud: CRUD?
    @Bindable var project: Project
    
    var body: some View {
        VStack{
            Text(project.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .lineLimit(1)
                .truncationMode(.tail)
            
            if(project.tracks.count == 0){
                Button(action: {
                    addTrack()
                }) {
                    Image(systemName: "plus.rectangle.portrait")
                        .font(.system(size: 200, weight: .bold))
                        .foregroundStyle(.primary)                 
                        .shadow(radius: 8)
                        .foregroundColor(.gray.opacity(0.8))
                        .transition(.scale.combined(with: .opacity))
                        .padding(100)
                }
            }
            
            ScrollView{
                VStack(spacing: 20){
                    ForEach(project.tracks) {track in
                        AudioTrackView(track: track, recordingSession: recordingSession)
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
                        Task{
                            await clearAll()
                            isAlertPresented = false
                        }
                    }
                })
            }
            .padding()
        }
        .task{
            await setupAudioSession()
        }
        .onAppear(){
            crud = CRUD(modelContext: modelContext)
        }
        
    }
    
    func addTrack(){
        let url = getDocumentsDirectory().appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        let newTrack = Track(id: UUID())
        
        project.tracks.append(newTrack)
    }
    
    func clearAll() async{
        do{
            try await crud?.removeAllTracksFromProject(project)
        } catch {
            print(error.localizedDescription)
        }
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

