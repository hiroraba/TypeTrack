//
//  TypingRecord.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public struct TypingRecord: Codable {
    public let category: String
    public let wpm: Double
    public let accuracy: Double
    public let score: Double
    public let timestamp: Date

    public init(category: String, wpm: Double, accuracy: Double, score: Double, timestamp: Date) {
        self.category = category
        self.wpm = wpm
        self.accuracy = accuracy
        self.score = score
        self.timestamp = timestamp
    }
}
