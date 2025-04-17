//
//  HighlightMistakeRepsitoryImpl.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation
import AppKit

final class HighlightMistakeRepositoryImpl: HighlightMistakeRepositoryProtocol {
    func highlightMistakes(_ expected: String, _ actual: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: expected)
        let expectedChars = Array(expected)
        let actualChars = Array(actual)

        for (index, char) in expectedChars.enumerated() {
            let range = NSRange(location: index, length: 1)
            if index < actualChars.count {
                if actualChars[index] == char {
                    attributed.addAttribute(.foregroundColor, value: NSColor.labelColor, range: range)
                } else {
                    attributed.addAttribute(.foregroundColor, value: NSColor.systemRed, range: range)
                }
            } else {
                attributed.addAttribute(.foregroundColor, value: NSColor.systemRed, range: range)
            }
        }
        return attributed
    }
}
