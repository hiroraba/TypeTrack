//
//  AnalyticsRepository.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/16.
//  
//

import Foundation

protocol AnalyticsRepositoryProtocol {
    func logGPTGenerated(category: TypingCategory, length: Int)
}
