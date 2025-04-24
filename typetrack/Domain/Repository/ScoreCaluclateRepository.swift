//
//  ScoreCaluclateRepository.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation

public protocol ScoreCalculateRepositoryProtocol {
    func calculate(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double
}
