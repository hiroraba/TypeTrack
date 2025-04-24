//
//  GetPersonalBestUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation

public protocol GetPersonalBestUseCaseProtocol {
    func execute() -> TypingRecord?
}

public final class GetPersonalBestUseCase: GetPersonalBestUseCaseProtocol {
    private let typingHistoryRepository: TypingHistoryRepositoryProtocol
    
    public init(typingHistoryRepository: TypingHistoryRepositoryProtocol) {
        self.typingHistoryRepository = typingHistoryRepository
    }
    
    public func execute() -> TypingRecord? {
        let typingRecords = typingHistoryRepository.fetchTypingHistory()
        return typingRecords.sorted(by: { $0.score > $1.score }).first
    }
}
