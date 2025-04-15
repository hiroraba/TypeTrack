//
//  TypingHistoryRepositoryImpl.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

public final class TypingHistoryRepositoryImpl: TypingHistoryRepositoryProtocol {
    
    private let key = "TypingRecords"
    
    public func fetchTypingHistory() -> [TypingRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([TypingRecord].self, from: data) else {
            return []
        }
        return records
    }
    
    public func saveTypingRecord(_ record: TypingRecord) {
        var records = fetchTypingHistory()
        records.append(record)
        
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    public init() {}
}
