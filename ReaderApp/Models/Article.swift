//
//  Article.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import Foundation

struct ArticlesResponse: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Decodable, Hashable {
    var id: String?
    var source: Source?
    var title: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: Date?
    
    var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case source, title, url, urlToImage, publishedAt
        case id
    }
    
    // Init for decoding from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        source = try? container.decode(Source.self, forKey: .source)
        title = try? container.decode(String.self, forKey: .title)
        url = try? container.decode(String.self, forKey: .url)
        urlToImage = try? container.decode(String.self, forKey: .urlToImage)
        publishedAt = try? container.decode(Date.self, forKey: .publishedAt)
        
        if let url = url {
            id = url
        } else {
            id = UUID().uuidString
        }
        
        isBookmarked = false
    }
    
    // Init for CoreData mapping
    init(
        id: String?,
        source: Source?,
        title: String?,
        url: String?,
        urlToImage: String?,
        publishedAt: Date?,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.source = source
        self.title = title
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.isBookmarked = isBookmarked
    }
}

struct Source: Codable, Hashable {
    let id: String?
    let name: String?
}
