//
//  NewsAPIClient.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation

protocol NewsAPIClientProtocol {
    func fetchArticles(country: String) async throws -> [Article]
}

// MARK: - Client Implementation
final class NewsAPIClient: NewsAPIClientProtocol {
    static let shared = NewsAPIClient()
    private init() {}
    
    func fetchArticles(
        country: String
    ) async throws -> [Article] {
        guard !Constants.newsApiKey.isEmpty else {
            throw APIError.missingAPIKey
        }
        
        var components = URLComponents(string: Constants.newsBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "apiKey", value: Constants.newsApiKey)
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        print(url)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1
            )
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(ArticlesResponse.self, from: data)
            return result.articles
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }
}
