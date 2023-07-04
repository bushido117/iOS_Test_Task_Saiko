//
//  APIService.swift
//  SaikoTestTask
//
//  Created by Вадим Сайко on 30.06.23.
//

import Foundation
import UIKit

struct APIService {
    
    enum APIError: Error {
        case invalidURL
        case invalidResponseStatus
        case dataTaskError
        case corruptData
        case decodingError
    }
    
    static func loadData<T: Codable>(
        for page: Int,
        type: T,
        completionHandler: @escaping (Result<T, APIError>) -> Void
    ) {
        guard var url = URL(string: "https://junior.balinasoft.com/api/v2/photo/type") else { completionHandler(.failure(.invalidURL))
            return
        }
        
        let item = URLQueryItem(name: "page", value: String(page))
        url.append(queryItems: [item])
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                completionHandler(.failure(.invalidResponseStatus))
                return
            }
            
            guard error == nil else {
                completionHandler(.failure(.dataTaskError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.corruptData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completionHandler(.success(decodedData))
            } catch {
                completionHandler(.failure(.decodingError))
                return
            }
        }
        .resume()
    }
    
    
    static func sendImage(_ image: PostModel) {
        guard let url = URL(string: "https://junior.balinasoft.com/api/v2/photo") else {
            print(APIError.invalidURL)
            return
        }

        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(image.name)".data(using: .utf8)!)
        
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
         body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(image.photo)
        
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(image.typeId)".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        session.uploadTask(with: urlRequest, from: body) { data, response, error in
            guard error == nil else {
               print(APIError.dataTaskError)
                return
            }
            
            guard let _ = response else {
                print(APIError.invalidResponseStatus)
                return
            }

            guard let data = data else {
                print(APIError.corruptData)
                return
            }
            print(String(data: data, encoding: .utf8))
        }
        .resume()
    }
}
