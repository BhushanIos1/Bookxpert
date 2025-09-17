//
//  CoreDataStack.swift
//  ReaderApp
//
//  Created by Bhushan Kumar on 15/09/25.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReaderModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() throws {
        let ctx = persistentContainer.viewContext
        if ctx.hasChanges {
            try ctx.save()
        }
    }
}
