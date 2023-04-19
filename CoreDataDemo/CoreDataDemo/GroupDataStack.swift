//
//  GroupDataStack.swift
//  CoreDataDemo
//
//  Created by Aiwei on 2023/4/19.
//

import Foundation
import CoreData

enum GroupDataStack: CoreDataStack {
    static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private static let groupIdentifer = "group.com.hellohezhili.test"
    
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataGroup")
        let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifer)!
        let sqlUrl = containerUrl.appendingPathComponent("group.sqlite")
        
        let description = NSPersistentStoreDescription(url: sqlUrl)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("\(Self.self) error \(error), \(error.userInfo)")
            } else {
                print(storeDescription.url?.absoluteString ?? "")
            }
        })
        return container
    }()
}
