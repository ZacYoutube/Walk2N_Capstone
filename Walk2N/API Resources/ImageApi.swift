//
//  ImageApi.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/4/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

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
    private let apiKey = ApiKeyObject.apiKey
    private let openaiImageApiUrl = "https://api.openai.com/v1/images/generations"
    private let openaiCompletionUrl = "https://api.openai.com/v1/completions"
    private let id = UUID().uuidString

    func generateImage(_ text: String, completion: @escaping (String?) -> Void) throws {
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
                
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion("No image error")
                return
            }
            
            guard let data = data else {
                completion("invalid image error")
                return
            }
            
            do {
                let results = try JSONDecoder().decode(Response.self, from: data)
                let imageURL = results.data[0].url
                
                let imgData = try Data(contentsOf: URL(string: imageURL)!)
                let storageRef = Storage.storage().reference().child("foodImages/\(UUID().uuidString)")

                let metadata = StorageMetadata()
                metadata.contentType = "image/png"
                storageRef.putData(imgData, metadata: metadata) { metaData, error in
                    if error == nil, metaData != nil {
                        storageRef.downloadURL { (url, error) in
                            if let url = url {
                                completion(url.absoluteString)
                            } else {
                                completion(nil)
                            }
                        }
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                completion("url does not work")
            }
        }
        task.resume()
    }
}
