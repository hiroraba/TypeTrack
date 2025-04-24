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
    private let personalBestUseCase: GetPersonalBestUseCase
    private let highlightMistakeUseCase: HighlightMistakeUseCase
    
    init(scoreCalculator: ScoreCalculatorUseCase,
         saveTypingRecordUseCase: SaveTypingRecordUseCase,
         generateTypingTaskUseCase: GenerateTypingTaskUseCase,
         analyticsRepository: AnalyticsRepositoryProtocol,
         personalBestUseCase: GetPersonalBestUseCase,
         highlightMistakeUseCase: HighlightMistakeUseCase) {
        
        self.scoreCalculator = scoreCalculator
        self.saveTypingRecordUseCase = saveTypingRecordUseCase
        self.generateTypingTaskUseCase = generateTypingTaskUseCase
        self.analyticsRepository = analyticsRepository
        self.personalBestUseCase = personalBestUseCase
        self.highlightMistakeUseCase = highlightMistakeUseCase
        
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
            .map { actual, expected, startTime in
                self.handleCompletion(actual: actual, expected: expected, startTime: startTime, category: currentCategory.value)
            }
            .bind(to: resultTextRelay)
            .disposed(by: disposeBag)
    }
    
    private func handleCompletion(actual: String, expected: String, startTime: Date, category: TypingCategory) -> String {
        let result = calculateTypingResult(actual: actual, expected: expected, startTime: startTime)
        
        
        let record = createTypingRecord(from: result, category: category)
        saveTypingRecordUseCase.execute(record: record)
        
        highlightedTaskText.accept(highlightMistakeUseCase.execute(expected: expected, actual: actual))
        
        return TypingResultFormatter().format(result)
    }
    
    private func calculateTypingResult(actual: String, expected: String, startTime: Date) -> TypingResult {
        let mistakeCount = calculateLevenshtein(actual: actual, expected: expected)
        let correctCount = expected.count - mistakeCount
        let accuracy = Double(correctCount) / Double(expected.count) * 100
        let elapsed = Date().timeIntervalSince(startTime)
        let wpm = Double(actual.count) / 5.0 / (elapsed / 60.0)
        let score = scoreCalculator.execute(wpm: wpm, accuracy: accuracy, length: expected.count, mistakeCount: mistakeCount)
        
        let previousBest = personalBestUseCase.execute()?.score ?? 0.0
        let isBest = score > previousBest
        
        return TypingResult(
            score: score,
            accuracy: accuracy,
            wpm: wpm,
            mistakeCount: mistakeCount,
            isBest: isBest,
            previousBest: previousBest
        )
    }
    
    private func createTypingRecord(from result: TypingResult, category: TypingCategory) -> TypingRecord {
        return TypingRecord(
            category: category.rawValue,
            wpm: result.wpm,
            accuracy: result.accuracy,
            score: result.score,
            timestamp: Date()
        )
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
}
