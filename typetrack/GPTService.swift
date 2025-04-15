//
//  GPTService.swift
//  typetrack
//
//  Created by matsuohiroki on 2025/04/14.
//
//

import Foundation

struct GPTService {

    static func generateTypingTask(category: String, completion: @escaping (String?) -> Void) {
        
        guard let apiKey = SettingViewController.loadApiKeyFromKeychain() else {
            print("Error: OpenAI API Key could not be loaded.")
            completion(nil)
            return
        }
        let commoncontent = """
        あなたはタイピング能力を向上を目的としたソフトウェアの課題文を作るAIです。以下の条件に従って、日本語のタイピング練習用課題文を1つ作成してください：
            • 最大200文字程度
            • 実在する情報・事実・テーマに基づく内容
            • 改行は不要
            • 英単語や記号（例：“NASA”, “3.14”, “&”, “love”など）を1つ以上含める
            • タイピング練習をしながら知識も得られるような内容にする
        """
        let prompt = Categories(rawValue: category)?.chatGPTPrompt ?? ""

        let messages = [
            ["role": "system", "content": commoncontent],
            ["role": "user", "content": prompt]
        ]

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String
            else {
                completion(nil)
                return
            }

            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}

import RxSwift

extension GPTService {
    static func generateTypingTaskObservable(category: String) -> Observable<String> {
        return Observable.create { observer in
            generateTypingTask(category: category) { result in
                observer.onNext(result!)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
