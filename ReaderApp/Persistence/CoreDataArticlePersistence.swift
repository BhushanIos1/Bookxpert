//
//  CoreDataArticlePersistence.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 16/09/25.
//

import Foundation
import CoreData

protocol ArticlePersistenceProtocol {
    // MARK: - Articles
    func saveOrUpdate(articles: [Article]) throws
    func fetchAllArticles() throws -> [Article]
    func fetchArticle(by id: String) throws -> Article?
    
    // MARK: - Bookmarks
    func addBookmark(article: Article) throws
    func removeBookmark(articleID: String) throws
    func fetchBookmarks() throws -> [Article]
    func isBookmarked(articleID: String) -> Bool
}

final class CoreDataArticlePersistence: ArticlePersistenceProtocol {
    static let shared = CoreDataArticlePersistence()
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    // MARK: - Articles
    
    /// Save or update articles while preserving bookmark status
    func saveOrUpdate(articles: [Article]) throws {
        for article in articles {
            let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", article.id ?? "")
            
            if let existing = try context.fetch(request).first {
                // Update fields but preserve bookmark state
                existing.title = article.title
                existing.url = article.url
                existing.urlToImage = article.urlToImage
                existing.publishedAt = article.publishedAt
                existing.sourceId = article.source?.id
                existing.sourceName = article.source?.name
            } else {
                _ = article.toEntity(in: context)
            }
        }
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    func fetchAllArticles() throws -> [Article] {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }
    
    func fetchArticle(by id: String) throws -> Article? {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first?.toDomain()
    }
    
    // MARK: - Bookmarks
    
    func addBookmark(article: Article) throws {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", article.id ?? "")
        
        if let entity = try context.fetch(request).first {
            entity.isBookmarked = true
        } else {
            let entity = article.toEntity(in: context)
            entity.isBookmarked = true
        }
        
        try context.save()
    }
    
    func removeBookmark(articleID: String) throws {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", articleID)
        if let entity = try context.fetch(request).first {
            entity.isBookmarked = false
            try context.save()
        }
    }
    
    func fetchBookmarks() throws -> [Article] {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == true")
        request.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        let entities = try context.fetch(request)
        return entities.map { $0.toDomain() }
    }
    
    func isBookmarked(articleID: String) -> Bool {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", articleID)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first?.isBookmarked ?? false
        } catch {
            return false
        }
    }
}
