//
//  HighlightMistakeRepository.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation

public protocol HighlightMistakeRepositoryProtocol {
    func highlightMistakes(_ expected: String, _ actual: String) -> NSAttributedString
}
