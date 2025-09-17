//
//  BookmarkViewModel.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 17/09/25.
//

import Foundation

@MainActor
final class BookmarkViewModel {
    // MARK: - Dependencies
    private let repository: ArticleRepositoryProtocol
    
    // MARK: - Data
    private(set) var bookmarks: [Article] = []
    
    // MARK: - Observers
    private var bookmarkObserver: NSObjectProtocol?
    
    // MARK: - UI Callbacks
    var onBookmarksUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Init
    init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
        
        // Observe bookmark changes globally
        bookmarkObserver = NotificationCenter.default.addObserver(
            forName: .bookmarksUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.loadBookmarks()
            }
        }
    }
    
    deinit {
        if let token = bookmarkObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Public API
    func loadBookmarks() {
        do {
            let stored = try repository.fetchBookmarks()
            self.bookmarks = stored
            onBookmarksUpdated?()
        } catch {
            onError?(error)
        }
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
    
    // MARK: - Table helpers
    func numberOfBookmarks() -> Int { bookmarks.count }
    func bookmark(at index: Int) -> Article { bookmarks[index] }
}

