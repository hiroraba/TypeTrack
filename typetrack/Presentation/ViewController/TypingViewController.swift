//
//  TypingViewController.swift
//  typetrack
//
//  Created by 松尾宏規 on 2025/04/14.
//

import AppKit
import RxSwift
import RxRelay

class TypingViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var taskLabel: NSTextField!
    @IBOutlet weak var generateButton: NSButton!
    
    @IBOutlet weak var inputScrollView: NSScrollView!
    
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var categorySelectButton: NSPopUpButton!
    @IBOutlet weak var resultLabel: NSTextField!
    
    private var viewModel: TypingViewModel!
    private let disposeBag = DisposeBag()
    private var startTime: Date?
    private var timer: Timer?
    
    private let categories: [TypingCategory] = [.meigen, .life, .science, .history, .technology, .culture, .art, .news, .phirosphy]
    
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
        
        guard let textView = inputScrollView.documentView as? NSTextView else { return }

        textView.delegate = self
        textView.font = NSFont.systemFont(ofSize: 24)

        let scoreUseCase = ScoreCalculatorUseCaseImpl()
        let saveUseCase = SaveTypingRecordUseCaseImpl(typingHistoryRepository: TypingHistoryRepositoryImpl())
        let generateUseCase = GenerateTypingTaskUseCaseImpl(generateTaskRepository: GenerateTaskRepositoryImpl())
        
        viewModel = TypingViewModel(scoreCalculator: scoreUseCase, saveTypingRecordUseCase: saveUseCase, generateTypingTaskUseCase: generateUseCase, analyticsRepository: AnalyticsRepositoryImpl())
        
        viewModel.taskText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.taskLabel.stringValue = text
                textView.isEditable = true
            })
            .disposed(by: disposeBag)
        
        viewModel.resultText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.resultLabel.stringValue = text
                self?.generateButton.isEnabled = true
            })
            .disposed(by: disposeBag)

        viewModel.highlightedTaskText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] attributed in
                self?.taskLabel.attributedStringValue = attributed
            })
            .disposed(by: disposeBag)
        
        viewModel.elapsedTime
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] elapsed in
                self?.timeLabel.stringValue = elapsed
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }

            if event.modifierFlags.contains(.command),
               event.keyCode == 36 { // 36 = Return key
                self.completeTypingAutomatically()
                return nil
            }

            return event
        }
    }

    @IBAction func didTapGenerate(_ sender: Any) {
        guard let inputTextView = inputScrollView.documentView as? NSTextView else { return }

        inputTextView.string = ""
        taskLabel.stringValue = ""
        resultLabel.stringValue = ""
        generateButton.isEnabled = false
        
        guard let selectedCategory = categorySelectButton.titleOfSelectedItem, let category = TypingCategory(rawValue: selectedCategory) else {
            return
        }
        
        viewModel.generateTrigger.accept(category)
    }
    
    @IBAction func generateTasks(_ sender: NSMenuItem) {
        didTapGenerate(sender)
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
       
        if startTime == nil && !textView.string.trimmingCharacters(in: .whitespaces).isEmpty {
            startTime = Date()
            startTimer()
        }
    }
    
    private func completeTypingAutomatically() {
        guard let startTime = startTime else { return }
        guard let inputTextView = inputScrollView.documentView as? NSTextView else { return }
        
        viewModel.completeTrigger.accept((userInput: inputTextView.string, startTime: startTime))
        
        inputTextView.isEditable = false
        
        self.timer?.invalidate()
        self.timer = nil
        self.startTime = nil
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            let elapsed = Date().timeIntervalSince(start)
            viewModel.updateElapsedTime(elapsed)
        }
    }
    
    @IBAction func showChart(_ sender: Any) {
        presentAsModalWindow(TypingGraphViewController())
    }
    
    @IBAction func showSetting(_ sender: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let settingVC = storyboard.instantiateController(withIdentifier: "SettingViewController") as? SettingViewController else {
            return
        }
        presentAsModalWindow(settingVC)
    }
}
