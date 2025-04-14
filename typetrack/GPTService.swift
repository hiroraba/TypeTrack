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
        
        guard let apiKey = loadAPIKeyFromEnvFile() else {
            print("Error: OpenAI API Key could not be loaded.")
            completion(nil)
            return
        }
        
        let prompt = """
タイピング練習用の日本語文章を1つ作ってください。
100〜200文字で自然な文章をお願いします。
見やすさを重視するために読点のあとは改行を挿入してください。

内容については下記の指定に従ってください。
指定: \(Categories(rawValue: category)?.chatGPTPrompt ?? "指定なし")
"""

        let messages = [
            ["role": "system", "content": "あなたはタイピング課題を作るAIです。"],
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

func loadAPIKeyFromEnvFile() -> String? {
    guard let envFilePath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("Error: .env not found in bundle.")
            return nil
        }

    guard FileManager.default.fileExists(atPath: envFilePath) else {
        print("Error: .env file not found at path: \(envFilePath)")
        return nil
    }

    guard let content = try? String(contentsOfFile: envFilePath, encoding: .utf8) else {
        print("Error: Could not read contents of .env file.")
        return nil
    }

    for line in content.components(separatedBy: .newlines) {
        let parts = line.components(separatedBy: "=")
        if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == "OPENAI_API_KEY" {
            return parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    print("Error: OPENAI_API_KEY not found in .env file.")
    return nil
}
