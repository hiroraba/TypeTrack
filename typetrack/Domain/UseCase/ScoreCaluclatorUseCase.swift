//
//  ScoreCaluclatorUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public protocol ScoreCalculatorUseCase {
    func calculate(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double
}

public final class ScoreCalculatorUseCaseImpl: ScoreCalculatorUseCase {
    public init() {}

    public func calculate(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double {
        let logWPM = log10(max(wpm, 1))
        let speedScore = min(logWPM / log10(80), 1.0)
        let accuracyScore = pow(min(accuracy / 100.0, 1.0), 1.5)
        let difficultyScore = min(Double(length) / 60.0, 1.0)
        let mistakePenalty = min(Double(mistakeCount) * 0.03, 0.4)

        let score = (speedScore * 0.5 + accuracyScore * 0.4 + difficultyScore * 0.1) - mistakePenalty
        return max(score * 100.0, 0.0)
    }
}
