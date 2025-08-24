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
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date?
    var updatedAt: Date?
    @Relationship(deleteRule: .cascade) var tracks: [Track] = []

    init(name: String, id: UUID) {
        self.name = name
        self.id = id
    }
}
