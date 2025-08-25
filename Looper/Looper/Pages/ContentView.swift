//
//  ContentView.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var projectName = ""
    @State private var isAlertPresented: Bool = false
    @State private var createdProject: Project?
    @State private var crud: CRUD?

    var body: some View {
        NavigationStack {
            List {
                ForEach(projects) { project in
                    NavigationLink(value: project){
                        Text(project.name)
                    }
                }.onDelete{ indexes in
                    for index in indexes {
                        Task{
                            do {
                                let project = projects[index]
                                try await crud?.removeProject(project)
                            } catch{
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .bottomBar){
                    Button(action: {
                        isAlertPresented = true
                    }) {
                        Text("Create a New Project")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .alert("Please enter a name:", isPresented: $isAlertPresented, actions: {
                TextField("Project Name", text: $projectName)
                Button("Cancel", role: .cancel) {
                    isAlertPresented = false
                    projectName = ""
                }
                Button("Create") {
                    let newProject = Project(name: projectName, id: UUID())
                    modelContext.insert(newProject)
                    try? modelContext.save()
                    createdProject = newProject
                    isAlertPresented = false
                    projectName = ""
                }
            })
            .navigationDestination(item: $createdProject) { project in
                ProjectView(project: project)
            }
            .navigationDestination(for: Project.self) { project in
                ProjectView(project: project)
            }
            .onAppear {
                crud = CRUD(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Project.self, Track.self])
}
