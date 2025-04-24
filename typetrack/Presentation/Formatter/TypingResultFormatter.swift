//
//  TypingResultFormatter.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/17.
//  
//

import Foundation

public final class TypingResultFormatter {
    public init() {}

    public func format(_ result: TypingResult) -> String {
        var message = String(format: "📊 Accuracy: %.1f%%\n⌨️ WPM: %.1f\n🏁 Score: %.1f", result.accuracy, result.wpm, result.score)

        if result.isBest {
            message += "\n👑 New Personal Best!"
        } else if let best = result.previousBest {
            message += String(format: "\n📈 Best: %.1f", best)
        }

        return message
    }
}
