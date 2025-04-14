//
//  ViewController.swift
//  typetrack
//
//  Created by 松尾宏規 on 2025/04/14.
//

import AppKit

class ViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var taskLabel: NSTextField!
    @IBOutlet weak var generateButton: NSButton!
    
    @IBOutlet weak var inputScrollView: NSScrollView!
    
    @IBOutlet weak var categorySelectButton: NSPopUpButton!
    @IBOutlet weak var resultLabel: NSTextField!
    private var startTime: Date?
    private let categories: [Categories] = [.meigen, .life, .science, .history, .technology, .culture]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        taskLabel.maximumNumberOfLines = 0
        taskLabel.lineBreakMode = .byWordWrapping
        
        inputScrollView.hasVerticalScroller = true
        inputScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        categorySelectButton.removeAllItems()
        categorySelectButton.addItems(withTitles: categories.map { $0.rawValue })
        
        if let textView = inputScrollView.documentView as? NSTextView {
            textView.delegate = self
            textView.font = NSFont.systemFont(ofSize: 24)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            // ⌘ + Return で完了処理
            if event.modifierFlags.contains(.command),
               event.keyCode == 36 { // 36 = Return key
                self.completeTypingAutomatically()
                return nil
            }

            return event
        }
    }

    @IBAction func didTapGenerate(_ sender: Any) {
        taskLabel.stringValue = ""
        generateButton.isEnabled = false

        guard let inputTextView = inputScrollView.documentView as? NSTextView else { return }
        
        let selectedCategory = categorySelectButton.titleOfSelectedItem ?? "名言"
        GPTService.generateTypingTask(category: selectedCategory) { [weak self] text in
            DispatchQueue.main.async {
                self?.generateButton.isEnabled = true
                inputTextView.isEditable = true
                if let text = text {
                    self?.taskLabel.stringValue = text
                    self?.startTime = Date()
                    AnalyticsEvent.gptGenerated(category: "名言", length: text.count)
                } else {
                    self?.taskLabel.stringValue = "error：failed genetate typing lesson"
                }
            }
        }
    }
    
    @IBAction func generateTasks(_ sender: NSMenuItem) {
        didTapGenerate(sender)
    }
    
    func calculateScore(wpm: Double, accuracy: Double, length: Int, mistakeCount: Int) -> Double {
        let logWPM = log10(max(wpm, 1))
        let speedScore = min(logWPM / log10(80), 1.0)

        let accuracyScore = pow(min(accuracy / 100.0, 1.0), 1.5)

        let difficultyScore = min(Double(length) / 60.0, 1.0)

        let mistakePenalty = min(Double(mistakeCount) * 0.03, 0.4)

        let score = (speedScore * 0.5 + accuracyScore * 0.4 + difficultyScore * 0.1) - mistakePenalty
        return max(score * 100.0, 0.0)
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        if startTime == nil && !textView.string.trimmingCharacters(in: .whitespaces).isEmpty {
            startTime = Date()
        }
    }
    
    private func completeTypingAutomatically() {
        guard let startTime = startTime else { return }
        guard let inputTextView = inputScrollView.documentView as? NSTextView else { return }
        let userInput = inputTextView.string
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        let correctCount = zip(taskLabel.stringValue, userInput).filter { $0 == $1 }.count
        let accuracy = Double(correctCount) / Double(taskLabel.stringValue.count) * 100
        let wpm = Double(userInput.count) / 5.0 / (elapsedTime / 60.0)
        
        let mistakeCount = max(userInput.count, taskLabel.stringValue.count) - correctCount
        
        let score = calculateScore(wpm: wpm, accuracy: accuracy, length: taskLabel.stringValue.count, mistakeCount: mistakeCount)
        
        let result = String(format: "accuracy: %.2f%%\nWPM: %.2f Score: %.2f", accuracy, wpm, score)
        
        resultLabel.stringValue = result
        
        let record = TypingRecord(
            category: categorySelectButton.titleOfSelectedItem ?? "名言",
            wpm: wpm,
            accuracy: accuracy,
            score: score,
            timestamp: Date()
        )
        TypingHistory.save(record)
        inputTextView.isEditable = false
    }
}
