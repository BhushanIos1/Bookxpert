//
//  ArticleEntity+Mapping.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import CoreData

extension ArticleEntity {
    func toDomain() -> Article {
        return Article(
            id: self.id,
            source: Source(id: self.sourceId, name: self.sourceName),
            title: self.title,
            url: self.url,
            urlToImage: self.urlToImage,
            publishedAt: self.publishedAt,
            isBookmarked: self.isBookmarked
        )
    }
    
    func update(from article: Article) {
        self.id = article.id
        self.sourceId = article.source?.id
        self.sourceName = article.source?.name
        self.title = article.title
        self.url = article.url
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.isBookmarked = article.isBookmarked
    }
}

extension Article {
    @discardableResult
    func toEntity(in context: NSManagedObjectContext) -> ArticleEntity {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", self.id ?? "")
        if let existing = (try? context.fetch(request))?.first {
            existing.update(from: self)
            return existing
        } else {
            let entity = ArticleEntity(context: context)
            entity.update(from: self)
            entity.isBookmarked = self.isBookmarked
            return entity
        }
    }
}
