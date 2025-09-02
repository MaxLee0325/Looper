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
    var bpm: Double = 120.0
    var introBeats = 4
    public var recorded: Bool = false
    public var playing: Bool = false
    public var recording: Bool = false
    public var number: Int?
    
    init(id: UUID = UUID()) {
        self.id = id
    }
    
    func setURL(url: URL){
        self.url = url
    }
    
    public func setBPM(bpm: Double){
        self.bpm = bpm
    }
    
    public func setIntroBeats(_ introBeats: Int){
        self.introBeats = introBeats
    }
    
    public func setBPM(_ bpm: Double){
        self.bpm = bpm
    }
    
    public func setNumber(_ number: Int){
        self.number = number
    }

}
