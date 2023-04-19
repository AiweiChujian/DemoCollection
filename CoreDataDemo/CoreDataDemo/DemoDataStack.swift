//
//  DemoDataStack.swift
//  CoreDataDemo
//
//  Created by Aiwei on 2023/4/19.
//

import Foundation
import CoreData

enum DemoDataStack: CoreDataStack {
    static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
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
