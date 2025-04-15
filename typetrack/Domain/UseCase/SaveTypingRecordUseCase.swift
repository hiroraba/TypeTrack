//
//  SaveTypingRecordUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public protocol SaveTypingRecordUseCase {
    func execute(record: TypingRecord)
}

public final class SaveTypingRecordUseCaseImpl: SaveTypingRecordUseCase {
    private let typingHistoryRepository: TypingHistoryRepositoryProtocol
    
    public init(typingHistoryRepository: TypingHistoryRepositoryProtocol) {
        self.typingHistoryRepository = typingHistoryRepository
    }
    
    public func execute(record: TypingRecord) {
        typingHistoryRepository.saveTypingRecord(record)
    }
}
