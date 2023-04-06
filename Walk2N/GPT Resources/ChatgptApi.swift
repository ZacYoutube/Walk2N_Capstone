//
//  GptApi.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/3/23.
//

import Foundation
import ChatGPTSwift

class GptApiService {
    private let apiKey = ""
    
    func fetchUrlRequest(url: String, httpMethod: String, messagePrompt: String, completion:((String) -> Void)?) {
        
        let api = ChatGPTAPI(apiKey: apiKey)

        Task {
            do {
                let response = try await api.sendMessage(text: messagePrompt,
                                                         model: "gpt-3.5-turbo",
                                                         systemText: "You are a nutritionist",
                                                         temperature: 0.5)
                completion!(response)
            } catch {
                print(error.localizedDescription)
                completion!(error.localizedDescription)
            }
        }
    }
}
