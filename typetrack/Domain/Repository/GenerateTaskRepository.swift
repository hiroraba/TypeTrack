//
//  GenerateTaskRepository.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation
import RxSwift

public protocol GenerateTaskRepositoryProtocol {
    func generateTask(_ category: TypingCategory) -> Observable<String>
}
