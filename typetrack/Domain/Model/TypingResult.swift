//
//  TypingResult.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation

public struct TypingResult {
    public let score: Double
    public let accuracy: Double
    public let wpm: Double
    public let mistakeCount: Int
    public let isBest: Bool
    public let previousBest: Double?
}
