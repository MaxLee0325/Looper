//
//  Recording.swift
//  Looper
//
//  Created by Max Lee on 2025-08-23.
//

import Foundation
import SwiftData

@Model
class Track: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date?
    var updatedAt: Date?
    var url: URL?
    var bpm: Double?
    
    init(id: UUID) {
        self.id = id
    }
    
    func setURL(url: URL){
        self.url = url
    }
    
    public func setBPM(bpm: Double){
        self.bpm = bpm
    }
}
