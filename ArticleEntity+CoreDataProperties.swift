//
//  ArticleEntity+CoreDataProperties.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 16/09/25.
//
//

import Foundation
import CoreData


extension ArticleEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleEntity> {
        return NSFetchRequest<ArticleEntity>(entityName: "ArticleEntity")
    }
    
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var publishedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var id: String?
    @NSManaged public var sourceId: String?
    @NSManaged public var sourceName: String?
    @NSManaged public var url: String?
}

extension ArticleEntity : Identifiable {
    
}
