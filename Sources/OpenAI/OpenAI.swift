import Foundation
import Alamofire

public class OpenAI {
    private let apiKey: String
    private let apiUrl = "https://api.openai.com/v1/engines/davinci-codex/completions"

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func complete(prompt: String, maxTokens: Int, completion: @escaping (Result<CompletionResult, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let parameters: [String: Any] = [
            "prompt": prompt,
            "max_tokens": maxTokens,
            "n": 1,
            "stop": ["\n"]
        ]

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: CompletionResponse.self) { response in
                switch response.result {
                    case .success(let completionResponse):
                        let completionResult = CompletionResult(choices: completionResponse.choices)
                        completion(.success(completionResult))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
    }
}

public struct CompletionResponse: Decodable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let usage: Usage
    public let choices: [Choice]

    public struct Usage: Decodable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
    }

    public struct Choice: Decodable {
        public let text: String
        public let index: Int
        public let logprobs: String?
        public let finishReason: String
    }
}

public struct CompletionResult {
    public let choices: [CompletionResponse.Choice]
}
