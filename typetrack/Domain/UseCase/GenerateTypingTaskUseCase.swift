//
//  GenerateTypingTaskUseCase.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation
import RxSwift

public protocol GenerateTypingTaskUseCase {
    func execute(category: TypingCategory) -> Observable<String>
}

class GenerateTypingTaskUseCaseImpl: GenerateTypingTaskUseCase {
    func execute(category: TypingCategory) -> Observable<String> {
        return generateTaskRepository.generateTask(category)
    }
    
    private let generateTaskRepository: GenerateTaskRepositoryProtocol
    
    init(generateTaskRepository: GenerateTaskRepositoryProtocol) {
        self.generateTaskRepository = generateTaskRepository
    }
}
