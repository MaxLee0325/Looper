//
//  Recording.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import Foundation
import SwiftData

@Model
class Recording: Identifiable {
    var id: UUID
    var projectId: UUID
    var createdAt: Date?
    var updatedAt: Date?
    var url: URL?
    
    init(id: UUID, projectID: UUID) {
        self.id = id
        self.projectId = projectID
    }
}
