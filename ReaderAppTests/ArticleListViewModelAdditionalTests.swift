//
//  ArticleListViewModelAdditionalTests.swift
//  ReaderAppTests
//
//  Created by Bhushan Kumar on 17/09/25.
//

import XCTest
@testable import ReaderApp

@MainActor
final class ArticleListViewModelAdditionalTests: XCTestCase {

    var repository: MockArticleRepository!
    var viewModel: ArticleListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockArticleRepository()
        viewModel = ArticleListViewModel(repository: repository)
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }

    func testLoadArticlesEmpty() async {
        repository.articles = []
        await viewModel.loadArticles()
        XCTAssertEqual(viewModel.filteredArticles.count, 0)
    }

    func testSearchNoMatches() async {
        let article = Article(id: "1", source: nil, title: "Hello", url: nil, urlToImage: nil, publishedAt: Date(), isBookmarked: false)
        repository.articles = [article]
        await viewModel.loadArticles()

        viewModel.search(query: "XYZ")
        XCTAssertEqual(viewModel.filteredArticles.count, 0)
    }

    func testSearchEmptyQueryRestoresAll() async {
        let article = Article(id: "1", source: nil, title: "Hello", url: nil, urlToImage: nil, publishedAt: Date(), isBookmarked: false)
        repository.articles = [article]
        await viewModel.loadArticles()

        viewModel.search(query: "")
        XCTAssertEqual(viewModel.filteredArticles.count, 1)
    }

    func testLoadArticlesWithError() async {
        repository.shouldThrowError = true

        var errorCalled = false
        viewModel.onError = { _ in errorCalled = true }

        await viewModel.loadArticles()
        XCTAssertTrue(errorCalled)
    }

    func testPullToRefreshKeepsBookmarks() async {
        let article1 = Article(id: "1", source: nil, title: "A", url: nil, urlToImage: nil, publishedAt: Date(), isBookmarked: false)
        let article2 = Article(id: "2", source: nil, title: "B", url: nil, urlToImage: nil, publishedAt: Date(), isBookmarked: false)
        repository.articles = [article1, article2]
        repository.bookmarks = ["1"]

        await viewModel.loadArticles()
        XCTAssertTrue(viewModel.filteredArticles.first?.isBookmarked ?? false)
        XCTAssertFalse(viewModel.filteredArticles.last?.isBookmarked ?? true)

        // Simulate pull to refresh
        repository.articles.append(Article(id: "3", source: nil, title: "C", url: nil, urlToImage: nil, publishedAt: Date(), isBookmarked: false))
        await viewModel.refreshArticles()
        XCTAssertEqual(viewModel.filteredArticles.count, 3)
        XCTAssertTrue(viewModel.filteredArticles.first?.isBookmarked ?? false)
    }
}

