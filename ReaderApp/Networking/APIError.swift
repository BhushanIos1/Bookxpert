//
//  APIError.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case networkError(underlying: Error)
    case httpError(statusCode: Int)
    case emptyData
    case decodingError(underlying: Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAPIKey, .missingAPIKey),
            (.invalidURL, .invalidURL),
            (.emptyData, .emptyData):
            return true
        case (.httpError(let l), .httpError(let r)):
            return l == r
        case (.networkError, .networkError),
            (.decodingError, .decodingError):
            return true
        default:
            return false
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Missing API Key. Set Constants.newsApiKey"
        case .invalidURL: return "Invalid URL"
        case .networkError(let underlying): return "Network error: \(underlying.localizedDescription)"
        case .httpError(let code): return "Server returned status code \(code)"
        case .emptyData: return "Empty response from server"
        case .decodingError(let underlying): return "Failed to decode response: \(underlying.localizedDescription)"
        }
    }
}

