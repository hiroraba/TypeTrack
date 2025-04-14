//
//  AnalyticsService.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/14.
//  
//

import FirebaseAnalytics

enum AnalyticsEvent {
    static func typingStarted(category: String, length: Int) {
        Analytics.logEvent("typing_started", parameters: [
            "category": category,
            "length": length
        ])
    }
    
    static func typingFinished(category: String, length: Int) {
        Analytics.logEvent("typing_finished", parameters: [
            "category": category,
            "length": length
        ])
    }
    
    static func gptGenerated(category: String, length: Int) {
        Analytics.logEvent("gpt_text_generated", parameters: [
            "category": category,
            "length": length
        ])
    }
}
