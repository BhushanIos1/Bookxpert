//
//  ArticleMappingTests.swift
//  ReaderAppTests
//
//  Created by Bhushan Kumar on 17/09/25.
//
import XCTest
@testable import ReaderApp

@MainActor
final class ArticleMappingTests: XCTestCase {
    
    func testArticleToEntityAndBack() throws {
        let article = Article(
            id: "1",
            source: Source(id: "source1", name: "NewsSource"),
            title: "Test Title",
            url: "https://example.com",
            urlToImage: "https://example.com/image.png",
            publishedAt: Date(),
            isBookmarked: false
        )
        
        let context = CoreDataStack.shared.context
        let entity = article.toEntity(in: context)
        
        XCTAssertEqual(entity.id, article.id)
        XCTAssertEqual(entity.isBookmarked, false)
        XCTAssertEqual(entity.sourceName, article.source?.name)
        
        let backToDomain = entity.toDomain()
        XCTAssertEqual(backToDomain.title, article.title)
        XCTAssertEqual(backToDomain.isBookmarked, false)
    }
}

