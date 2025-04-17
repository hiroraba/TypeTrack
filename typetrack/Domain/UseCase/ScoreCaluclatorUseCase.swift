//
//  ScoreCaluclatorUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public protocol ScoreCalculatorUseCase {
    func execute(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double
}

public final class ScoreCalculatorUseCaseImpl: ScoreCalculatorUseCase {
    
    public func execute(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double {
        return repository.calculate(wpm: wpm, accuracy: accuracy, length: length, mistakeCount: mistakeCount)
    }
    
    let repository: ScoreCalculateRepositoryProtocol

    init(repository: ScoreCalculateRepositoryProtocol) {
        self.repository = repository
    }
}
