//
//  ArticleRepository.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation
import CoreData

protocol ArticleRepositoryProtocol {
    func fetchArticles(country: String) async throws -> [Article]
    func fetchCachedArticles() throws -> [Article]
    
    // Bookmarks
    func addBookmark(article: Article) async throws
    func removeBookmark(articleID: String) async throws
    func fetchBookmarks() throws -> [Article]
    func isBookmarked(articleID: String) async -> Bool
}

final class ArticleRepository: ArticleRepositoryProtocol {
    private let apiClient: NewsAPIClient
    private let persistence: ArticlePersistenceProtocol
    
    init(apiClient: NewsAPIClient, persistence: ArticlePersistenceProtocol) {
        self.apiClient = apiClient
        self.persistence = persistence
    }
    
    // MARK: - Articles
    
    func fetchArticles(country: String) async throws -> [Article] {
        let freshArticles = try await apiClient.fetchArticles(country: country)
        
        try persistence.saveOrUpdate(articles: freshArticles)
        
        return try persistence.fetchAllArticles()
    }
    
    func fetchCachedArticles() throws -> [Article] {
        return try persistence.fetchAllArticles()
    }
    
    // MARK: - Bookmarks
    
    func addBookmark(article: Article) async throws {
        try persistence.addBookmark(article: article)
    }
    
    func removeBookmark(articleID: String) async throws {
        try persistence.removeBookmark(articleID: articleID)
    }
    
    func fetchBookmarks() throws -> [Article] {
        return try persistence.fetchBookmarks()
    }
    
    func isBookmarked(articleID: String) async -> Bool {
        return persistence.isBookmarked(articleID: articleID)
    }
}
