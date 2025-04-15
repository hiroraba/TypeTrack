//
//  TypingGraphViewModel.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation
import RxSwift
import RxRelay

final class TypingGraphViewModel {
    
    let records: Observable<[TypingRecord]>
    
    private let recordsRelay = BehaviorRelay<[TypingRecord]>(value: [])
    private let loadTypingHistoryUseCase: LoadTypingHistoryUseCase
    private let disposeBag = DisposeBag()
    
    init(loadTypingHistoryUseCase: LoadTypingHistoryUseCase) {
        self.loadTypingHistoryUseCase = loadTypingHistoryUseCase
        self.records = recordsRelay.asObservable()
        loadTypingHistory()
    }
    
    private func loadTypingHistory() {
        let records = loadTypingHistoryUseCase.execute()
        recordsRelay.accept(records)
    }
}
