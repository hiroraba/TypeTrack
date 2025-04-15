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
    let generateTrigger = PublishRelay<String>()
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
    
    init(scoreCalculator: ScoreCalculatorUseCase, saveTypingRecordUseCase: SaveTypingRecordUseCase) {
        self.scoreCalculator = scoreCalculator
        self.saveTypingRecordUseCase = saveTypingRecordUseCase
        taskText = taskTextRelay.asObservable()
        resultText = resultTextRelay.asObservable()
        bind()
    }

    private func bind() {
        
        let currentCategory = BehaviorRelay<String>(value: "")
        
        generateTrigger
            .do(onNext: { category in
                currentCategory.accept(category)
            })
            .flatMap { category -> Observable<String> in
                GPTService.generateTypingTaskObservable(category: category)
            }
            .compactMap { $0 }
            .do(onNext: { [weak self] text in
                self?.taskTextRelay.accept(text)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        completeTrigger
            .withLatestFrom(taskTextRelay) { input, expected in
                (input.userInput, expected, input.startTime)
            }
            .map { actual, expected, startTime -> String in
                let correctCount = zip(expected, actual).filter { $0 == $1 }.count
                let mistakeCount = max(expected.count, actual.count) - correctCount
                let accuracy = Double(correctCount) / Double(expected.count) * 100
                let elapsed = Date().timeIntervalSince(startTime)
                let wpm = Double(actual.count) / 5.0 / (elapsed / 60.0)
                let score = self.scoreCalculator.calculate(wpm: wpm, accuracy: accuracy, length: expected.count, mistakeCount: mistakeCount)
            
                let record = TypingRecord(
                    category: currentCategory.value,
                    wpm: wpm,
                    accuracy: accuracy,
                    score: score,
                    timestamp: Date()
                )
                
                self.saveTypingRecordUseCase.execute(record: record)
                
                let attributed = NSMutableAttributedString(string: expected)
                for (index, (eChar, aChar)) in zip(expected, actual).enumerated() {
                    let color: NSColor = (eChar == aChar) ? .labelColor : .systemRed
                    attributed.addAttribute(.foregroundColor, value: color, range: NSRange(location: index, length: 1))
                }
                if actual.count < expected.count {
                    let range = NSRange(location: actual.count, length: expected.count - actual.count)
                    attributed.addAttribute(.foregroundColor, value: NSColor.systemRed, range: range)
                }
                self.highlightedTaskText.accept(attributed)
                    
                return String(format: "📊 accuracy: %.2f%%\nWPM: %.2f Score: %.2f", accuracy, wpm, score)
            }
            .bind(to: resultTextRelay)
            .disposed(by: disposeBag)
    }
    
    func updateElapsedTime(_ time: TimeInterval) {
        elapsedTime.accept(String(format: "🕰️ Elapsed Time: %.2f sec 🕰️", time))
    }
}
