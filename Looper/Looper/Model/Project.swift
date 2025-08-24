//
//  Project.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import Foundation
import SwiftData

@Model
class Project: Identifiable {
    var id: UUID
    var name: String
    var createdAt: Date?
    var updatedAt: Date?
    var recordings: [UUID]?
    
    init(name: String, id: UUID) {
        self.name = name
        self.id = id
    }
    
    func addRecording(id: UUID) {
        self.recordings?.append(id)
    }
    
    func removeRecording(id: UUID) {
        if var recordings = self.recordings {
            recordings.removeAll { $0 == id }
            self.recordings = recordings
        }
    }
    
    func removeAllRecordings(){
        self.recordings?.removeAll()
    }
    
}
