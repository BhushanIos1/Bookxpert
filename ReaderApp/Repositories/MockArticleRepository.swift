//
//  MockArticleRepository.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 17/09/25.
//

import Foundation

final class MockArticleRepository: ArticleRepositoryProtocol {
    var articles: [Article] = []
    var bookmarks: Set<String> = []
    var shouldThrowError: Bool = false
    
    func fetchArticles(country: String) async throws -> [Article] {
        if shouldThrowError { throw NSError(domain: "Test", code: 1) }
        return articles
    }
    
    func fetchCachedArticles() throws -> [Article] {
        if shouldThrowError { throw NSError(domain: "Test", code: 1) }
        return articles
    }
    
    func fetchBookmarks() throws -> [Article] {
        if shouldThrowError { throw NSError(domain: "Test", code: 1) }
        return articles.filter { bookmarks.contains($0.id ?? "") }
    }
    
    func addBookmark(article: Article) async throws {
        if shouldThrowError { throw NSError(domain: "Test", code: 1) }
        if let id = article.id { bookmarks.insert(id) }
    }
    
    func removeBookmark(articleID: String) async throws {
        if shouldThrowError { throw NSError(domain: "Test", code: 1) }
        bookmarks.remove(articleID)
    }
    
    func isBookmarked(articleID: String) async -> Bool {
        return bookmarks.contains(articleID)
    }
}
