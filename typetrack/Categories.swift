//
//  Categories.swift
//  typetrack
//  
//  Created by matsuohiroki on 2025/04/15.
//  
//

import Foundation

enum Categories: String {
    case meigen = "名言"
    case life = "生活"
    case science = "科学"
    case history = "歴史"
    case technology = "技術"
    case culture = "文化"
    
    var chatGPTPrompt: String {
        switch self {
        case .meigen:
            return "一つ有名な名言をピックアップし、それを解説する文章を作成してください。"
        case .life:
            return "日常生活に関する文章を作成してください。砕けた感じの話言葉で良いですが、一人称でお願いします。"
        case .science:
            return "自然科学に関する文章を作成してください。"
        case .history:
            return "歴史に関する文章を作成してください。日本史、世界史、近現代史などジャンルは指定しません。"
        case .technology:
            return "技術に関する文章を作成してください。情報技術、機械工学や遺伝子工学などジャンルは指定しません。"
        case .culture:
            return "文化、芸術に関する文章を作成してください。絵画、映画、商業デザインなどジャンルは幅広くて良いですが、文章は一ジャンルのみに絞ってください。"
        }
        
        
    }
}
