//
//  TypingGraphObservableAdapter.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation
import Combine

import RxSwift
import RxRelay

final class TypingGraphObservableAdapter: ObservableObject {
    
    @Published var records: [TypingRecord] = []
    
    private let viewModel: TypingGraphViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: TypingGraphViewModel) {
        self.viewModel = viewModel
        
        viewModel.records
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.records = records
            })
            .disposed(by: disposeBag)
    }
}
