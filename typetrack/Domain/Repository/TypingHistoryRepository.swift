//
//  TypingHistoryRepository.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public protocol TypingHistoryRepositoryProtocol {
    func fetchTypingHistory() -> [TypingRecord]
    func saveTypingRecord(_ record: TypingRecord)
}
