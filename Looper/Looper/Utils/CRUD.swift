//
//  CRUD.swift
//  Looper
//
//  Created by Max Lee on 2025-08-24.
//

import Foundation
import SwiftUI
import SwiftData

class CRUD: ObservableObject {
    
    public var modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func removeProject(_ project: Project) async throws {
        try await removeAllTracksFromProject(project)
        modelContext.delete(project)
        try modelContext.save()
    }

    public func removeAllTracksFromProject(_ project: Project) async throws {
        if project.tracks.count > 0 {
            for track in project.tracks {
                try await removeTrack(track)
                modelContext.delete(track)
            }
            project.tracks.removeAll()
        }
    }
    
    public func removeTrack(_ track: Track) async throws {
        if let url = track.url {
            do {
                try await deleteFile(url: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func deleteFile(url: URL) async throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Failed to remove file: \(error.localizedDescription)")
            }
        } else {
            print("No file found at: \(url.path)")
        }
    }
}
