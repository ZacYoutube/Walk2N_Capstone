//
//  ImageApi.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/4/23.
//

import Foundation
import UIKit

struct Response: Decodable {
    let data: [ImageUrl]
}

struct ImageUrl: Decodable {
    let url: String
}

enum RetrieveImageError: Error {
    case unableToGetUrl
    case unableToCreateUrl
    case unableToGetImage
}

class ImageApiService {
    private let apiKey = "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"
    private let openaiImageApiUrl = "https://api.openai.com/v1/images/generations"
    private let openaiCompletionUrl = "https://api.openai.com/v1/completions"
    private let id = UUID().uuidString

    func generateImage(_ text: String) async throws -> UIImage {
        let param: [String: Any] = [
            "prompt": text,
            "n": 1,
            "size": "1024x1024",
            "user": id
        ]
        
        let data: Data = try JSONSerialization.data(withJSONObject: param)
        
        guard let url = URL(string: openaiImageApiUrl) else {
            throw RetrieveImageError.unableToGetUrl
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        
        let (response, _) = try await URLSession.shared.data(for: urlRequest)
        
        
        let results = try JSONDecoder().decode(Response.self, from: response)
        
        let imageURL = results.data[0].url
        guard let imageURL = URL(string: imageURL) else {
            throw RetrieveImageError.unableToCreateUrl
        }
                
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                
        guard let image = UIImage(data: imageData) else {
            throw RetrieveImageError.unableToGetImage
        }
        
        return image
        
    }
}
