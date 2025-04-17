//
//  HighlightMistakeUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation
import AppKit

public protocol HighlightMistakeUseCase {
    func execute(expected: String, actual: String) -> NSAttributedString
}

public final class HighlightMistakeUseCaseImpl: HighlightMistakeUseCase {

    let repository: HighlightMistakeRepositoryProtocol
    
    public func execute(expected: String, actual: String) -> NSAttributedString {
        return repository.highlightMistakes(expected, actual)
    }
    
    init(repository: HighlightMistakeRepositoryProtocol) {
        self.repository = repository
    }
}
