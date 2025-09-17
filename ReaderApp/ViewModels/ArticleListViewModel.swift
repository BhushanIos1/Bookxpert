//
//  ArticleListViewModel.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation

@MainActor
final class ArticleListViewModel {
    // MARK: - Dependencies
    private let repository: ArticleRepositoryProtocol
    
    // MARK: - Data
    private(set) var allArticles: [Article] = []
    private(set) var filteredArticles: [Article] = []
    
    // MARK: - Observers
    private var bookmarkObserver: NSObjectProtocol?
    
    // MARK: - UI Callbacks
    var onLoadingStateChange: ((Bool) -> Void)?
    var onArticlesUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Init
    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
        
        // Observe bookmark changes so the feed updates isBookmarked flags in real-time
        bookmarkObserver = NotificationCenter.default.addObserver(
            forName: .bookmarksUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.handleBookmarksUpdated()
            }
        }
    }
    
    deinit {
        if let token = bookmarkObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Public API
    func loadArticles(country: String = "us") async {
        onLoadingStateChange?(true)
        
        // Load cached first
        if let cached = try? repository.fetchCachedArticles(), !cached.isEmpty {
            self.allArticles = cached
            self.filteredArticles = cached
            refreshBookmarkState()
            onArticlesUpdated?()
        }
        
        do {
            let fresh = try await repository.fetchArticles(country: country)
            self.allArticles = fresh
            self.filteredArticles = fresh
            refreshBookmarkState()
            onArticlesUpdated?()
        } catch {
            if allArticles.isEmpty {
                onError?(error)
            } else {
                onError?(error)
            }
        }
        
        onLoadingStateChange?(false)
    }
    
    func refreshArticles(country: String = "us") async {
        onLoadingStateChange?(true)
        do {
            let fresh = try await repository.fetchArticles(country: country)
            self.allArticles = fresh
            self.filteredArticles = fresh
            refreshBookmarkState()
            onArticlesUpdated?()
        } catch {
            onError?(error)
        }
        onLoadingStateChange?(false)
    }
    
    func search(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            filteredArticles = allArticles
            onArticlesUpdated?()
            return
        }
        
        filteredArticles = allArticles.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(q)
        }
        onArticlesUpdated?()
    }
    
    func toggleBookmark(for article: Article) {
        Task.detached { [weak self] in
            guard let self else { return }
            let articleID = article.id ?? UUID().uuidString
            do {
                if await self.repository.isBookmarked(articleID: articleID) {
                    try await self.repository.removeBookmark(articleID: articleID)
                } else {
                    try await self.repository.addBookmark(article: article)
                }
                NotificationCenter.default.post(name: .bookmarksUpdated, object: nil)
            } catch {
                await MainActor.run {
                    self.onError?(error)
                }
            }
        }
    }
    
    func loadBookmarks() {
        do {
            let bookmarks = try repository.fetchBookmarks()
            self.allArticles = bookmarks
            self.filteredArticles = bookmarks
            onArticlesUpdated?()
        } catch {
            onError?(error)
        }
    }
    
    // MARK: - Helpers
    private func refreshBookmarkState() {
        do {
            let bookmarks = try repository.fetchBookmarks()
            let bookmarkedIDs = Set(bookmarks.compactMap { $0.id })
            
            self.allArticles = self.allArticles.map { article in
                var updated = article
                updated.isBookmarked = bookmarkedIDs.contains(article.id ?? "")
                return updated
            }
            self.filteredArticles = self.filteredArticles.map { article in
                var updated = article
                updated.isBookmarked = bookmarkedIDs.contains(article.id ?? "")
                return updated
            }
            onArticlesUpdated?()
        } catch {
            // ignore errors here
        }
    }
    
    @objc private func handleBookmarksUpdated() {
        refreshBookmarkState()
    }
    
    // MARK: - Table helpers
    func numberOfArticles() -> Int { filteredArticles.count }
    func article(at index: Int) -> Article { filteredArticles[index] }
}
