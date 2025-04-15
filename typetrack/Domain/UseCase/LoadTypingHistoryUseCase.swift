//
//  LoadTypingHistoryUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public protocol LoadTypingHistoryUseCase {
    func execute() -> [TypingRecord]
}

public final class LoadTypingHistoryUseCaseImpl: LoadTypingHistoryUseCase {
    private let typingHistoryRepository: TypingHistoryRepositoryProtocol
    
    public init(typingHistoryRepository: TypingHistoryRepositoryProtocol) {
        self.typingHistoryRepository = typingHistoryRepository
    }
    
    public func execute() -> [TypingRecord] {
        return typingHistoryRepository.fetchTypingHistory()
    }
}
