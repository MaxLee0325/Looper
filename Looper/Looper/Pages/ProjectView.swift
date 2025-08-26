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
    @State private var showTempoSheet = false
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
            
            ScrollView{
                VStack(spacing: 20){
                    ForEach(project.tracks) {track in
                        AudioTrackView(track: track, recordingSession: recordingSession)
                    }
                    .padding()
                }
                Button(action: {
                    addTrack()
                }) {
                    Image(systemName: "plus.rectangle.portrait")
                        .font(.system(size: 160, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(radius: 8)
                        .foregroundColor(.gray.opacity(0.8))
                        .transition(.scale.combined(with: .opacity))
                        .padding(100)
                }
                .sheet(isPresented: $showTempoSheet) {
                    TempoSheet(tempo: $project.bpm, introBeats: $project.introBeats)
                }
            }
            
            HStack{
                
                Button(action: {
                    showTempoSheet = true
                }){
                    Text("\(Int(project.bpm)) \n BPM")
                        .foregroundColor(.blue)              // text color
                        .font(.system(size: 20, weight: .bold)) // text size + weight
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2)) // same gray background
                        .clipShape(Circle())
                }
                
                Button(action:{
                    isAlertPresented = true
                }) {
                    Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: 100, height: 100)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
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

