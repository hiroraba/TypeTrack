//
//  TypingViewModel.swift
//  typetrack
//
//  Created by matsuohiroki on 2025/04/15.
//
//

import Foundation
import RxSwift
import RxRelay
import AppKit

final class TypingViewModel {
    let generateTrigger = PublishRelay<TypingCategory>()
    let completeTrigger = PublishRelay<(userInput: String, startTime: Date)>()
    
    let taskText: Observable<String>
    let resultText: Observable<String>

    let elapsedTime = BehaviorRelay<String>(value: "")
    
    private let resultTextRelay = PublishRelay<String>()
    private let taskTextRelay = BehaviorRelay<String>(value: "")
    let highlightedTaskText = PublishRelay<NSAttributedString>()
    
    private let disposeBag = DisposeBag()
    private let scoreCalculator: ScoreCalculatorUseCase
    private let saveTypingRecordUseCase: SaveTypingRecordUseCase
    private let generateTypingTaskUseCase: GenerateTypingTaskUseCase
    private let analyticsRepository: AnalyticsRepositoryProtocol
    
    init(scoreCalculator: ScoreCalculatorUseCase, saveTypingRecordUseCase: SaveTypingRecordUseCase, generateTypingTaskUseCase: GenerateTypingTaskUseCase, analyticsRepository: AnalyticsRepositoryProtocol) {
        
        self.scoreCalculator = scoreCalculator
        self.saveTypingRecordUseCase = saveTypingRecordUseCase
        self.generateTypingTaskUseCase = generateTypingTaskUseCase
        self.analyticsRepository = analyticsRepository
        
        taskText = taskTextRelay.asObservable()
        resultText = resultTextRelay.asObservable()
        bind()
    }

    private func bind() {
        
        let currentCategory = BehaviorRelay<TypingCategory>(value: .news)
        
        generateTrigger
            .do(onNext: { category in
                currentCategory.accept(category)
            })
            .flatMap { [weak self] category -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.generateTypingTaskUseCase.execute(category: category)
            }
            .compactMap { $0 }
            .do(onNext: { [weak self] text in
                self?.taskTextRelay.accept(text)
                self?.analyticsRepository.logGPTGenerated(category: currentCategory.value, length: text.count)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        completeTrigger
            .withLatestFrom(taskTextRelay) { input, expected in
                (input.userInput, expected, input.startTime)
            }
            .map { actual, expected, startTime -> String in
                
                let mistakeCount = self.calculateLevenshtein(actual: actual, expected: expected)

                let correctCount = expected.count - mistakeCount
                let accuracy = Double(correctCount) / Double(expected.count) * 100
                let elapsed = Date().timeIntervalSince(startTime)
                let wpm = Double(actual.count) / 5.0 / (elapsed / 60.0)
                let score = self.scoreCalculator.calculate(wpm: wpm, accuracy: accuracy, length: expected.count, mistakeCount: mistakeCount)
            
                let record = TypingRecord(
                    category: currentCategory.value.rawValue,
                    wpm: wpm,
                    accuracy: accuracy,
                    score: score,
                    timestamp: Date()
                )
                
                self.saveTypingRecordUseCase.execute(record: record)
                
                let attributed = self.generateHighlightedText(expected: expected, actual: actual)
                self.highlightedTaskText.accept(attributed)
                    
                return String(format: "📊 accuracy: %.2f%%\nWPM: %.2f Score: %.2f", accuracy, wpm, score)
            }
            .bind(to: resultTextRelay)
            .disposed(by: disposeBag)
    }
    
    func updateElapsedTime(_ time: TimeInterval) {
        elapsedTime.accept(String(format: "🕰️ Elapsed Time: %.2f sec", time))
    }
    
    // swiftlint:disable identifier_name
    private func calculateLevenshtein(actual: String, expected: String) -> Int {
        let aChars = Array(actual)
        let bChars = Array(expected)
        let n = aChars.count
        let m = bChars.count

        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)

        for i in 0...n { dp[i][0] = i }
        for j in 0...m { dp[0][j] = j }

        for i in 1...n {
            for j in 1...m {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(
                        dp[i - 1][j],
                        dp[i][j - 1],
                        dp[i - 1][j - 1]
                    ) + 1
                }
            }
        }

        return dp[n][m]
    }

    private func generateHighlightedText(expected: String, actual: String) -> NSAttributedString {
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
