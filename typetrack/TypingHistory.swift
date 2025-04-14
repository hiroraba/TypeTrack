//
//  TypingHistory.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/14.
//  
//

import Foundation

struct TypingRecord: Codable {
    let category: String
    let wpm: Double
    let accuracy: Double
    let score: Double
    let timestamp: Date
}

class TypingHistory {
    static private let key = "TypingRecords"

    static func save(_ record: TypingRecord) {
        var records = load()
        records.append(record)
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [TypingRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([TypingRecord].self, from: data) else {
            return []
        }
        return records
    }

    static func analyzeByCategory() -> [String: (averageWPM: Double, averageAccuracy: Double, avrageScore: Double)] {
        let records = load()
        let grouped = Dictionary(grouping: records, by: { $0.category })

        return grouped.mapValues { group in
            let totalWPM = group.reduce(0) { $0 + $1.wpm }
            let totalAccuracy = group.reduce(0) { $0 + $1.accuracy }
            let totalScore = group.reduce(0) { $0 + $1.score }
            let count = Double(group.count)
            return (totalWPM / count, totalAccuracy / count, totalScore / count)
        }
    }
}
