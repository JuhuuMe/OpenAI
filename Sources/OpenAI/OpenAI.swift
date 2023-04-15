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

public struct ChatCompletionRequest: Codable {
    public let model: String
    public let messages: [Message]
    
    public struct Message: Codable {
        public let role: String
        public let content: String

        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
    }
}

public struct ChatCompletionResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let usage: Usage
    public let choices: [Choice]

    public struct Usage: Codable {
        public let prompt_tokens: Int
        public let completion_tokens: Int
        public let total_tokens: Int
    }

    public struct Choice: Codable {
        public let message: Message
        public let finish_reason: String
        public let index: Int
        
        public struct Message: Codable {
            public let role: String
            public let content: String
        }
    }
}


public class OpenAI {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func chatCompletion(model: String = "gpt-3.5-turbo", messages: [ChatCompletionRequest.Message], completion: @escaping (Result<ChatCompletionResponse, Error>) -> Void) {
        let requestPayload = ChatCompletionRequest(model: model, messages: messages)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]

        AF.request(baseURL, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: ChatCompletionResponse.self) { (response: DataResponse<ChatCompletionResponse, AFError>) in
                switch response.result {
                case .success(let chatCompletionResult):
                    completion(.success(chatCompletionResult))
                case .failure(let error):
                    print("Raw response data: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")") // Added this line to print raw response data
                    completion(.failure(error))
                }
            }
    }


}
