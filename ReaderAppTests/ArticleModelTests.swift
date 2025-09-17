//
//  ArticleModelTests.swift
//  ReaderAppTests
//
//  Created by Bhushan Kumar on 17/09/25.
//

import XCTest
@testable import ReaderApp

final class ArticleModelTests: XCTestCase {
    
    func testTimeAgo() {
        let now = Date()
        
        let tenSecondsAgo = now.addingTimeInterval(-10)
        let oneMinuteAgo = now.addingTimeInterval(-60)
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let yesterday = now.addingTimeInterval(-86400)
        
        XCTAssertEqual(tenSecondsAgo.timeAgo(), "10 seconds ago")
        XCTAssertEqual(oneMinuteAgo.timeAgo(), "1 minute ago")
        XCTAssertEqual(twoHoursAgo.timeAgo(), "2 hours ago")
        XCTAssertEqual(yesterday.timeAgo(), "Yesterday")
    }
    
    func testArticleIDFallback() throws {
        let article = Article(
            id: nil,
            source: nil,
            title: "Test Article",
            url: "https://example.com",
            urlToImage: nil,
            publishedAt: nil,
            isBookmarked: false
        )
        
        // ID should fallback to url
        XCTAssertNotNil(article.id)
        XCTAssertEqual(article.id, article.url)
    }
    
    func testArticleIDUUIDFallback() throws {
        let article = Article(
            id: nil,
            source: nil,
            title: "No URL Article",
            url: nil,
            urlToImage: nil,
            publishedAt: nil,
            isBookmarked: false
        )
        
        XCTAssertNotNil(article.id)
    }
}
