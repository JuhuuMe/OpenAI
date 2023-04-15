import Foundation
import Alamofire

public struct CompletionResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let usage: Usage
    public let choices: [Choice]

    public struct Usage: Codable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
    }

    public struct Choice: Codable {
        public let text: String
        public let index: Int
        public let logprobs: LogProbs?
        public let finishReason: String

        public struct LogProbs: Codable {
            public let tokens: [String]
            public let tokenLogprobs: [Double]
            public let topLogprobs: [[String: Double]]
            public let textOffset: [Int]
        }
    }
}

struct CompletionRequest: Codable {
    let model: String
    let prompt: String
    let maxTokens: Int
    let temperature: Double
}

public class OpenAI {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/completions"

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func complete(prompt: String, maxTokens: Int, temperature: Double, completion: @escaping (Result<CompletionResponse, Error>) -> Void) {
        let requestPayload = CompletionRequest(model: "text-davinci-003", prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        AF.request(baseURL, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: CompletionResponse.self) { response in
                switch response.result {
                case .success(let completionResult):
                    completion(.success(completionResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
