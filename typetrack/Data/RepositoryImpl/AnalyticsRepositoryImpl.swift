//
//  AnalyticsRepositoryImpl.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/16.
//  
//

import Foundation
import FirebaseAnalytics

final class AnalyticsRepositoryImpl: AnalyticsRepositoryProtocol {
    func logGPTGenerated(category: TypingCategory, length: Int) {
        Analytics.logEvent("gpt_text_generated", parameters: [
            "category": category.rawValue,
            "length": length
        ])
    }
}
