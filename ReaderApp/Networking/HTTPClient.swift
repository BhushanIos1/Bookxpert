//
//  HTTPClient.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation

protocol HTTPClient {
    func getData(from url: URL) async throws -> (Data, HTTPURLResponse)
}

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let monitor = NetworkMonitor.shared
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        guard monitor.isConnected else {
            throw APIError.networkError(underlying: URLError(.notConnectedToInternet))
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidURL
            }
            return (data, httpResponse)
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.networkError(underlying: URLError(.timedOut))
        } catch {
            throw APIError.networkError(underlying: error)
        }
    }
}
