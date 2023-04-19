//
//  CoreDataStack.swift
//  CoreDataDemo
//
//  Created by Aiwei on 2023/4/19.
//

import Foundation
import CoreData

protocol CoreDataStack {
    static var context: NSManagedObjectContext { get }
}

extension CoreDataStack {
    static func synchronize() throws {
        let context = context
        guard context.hasChanges else {
            return
        }
        try context.save()
    }
}

extension CoreDataStack {
    /// 增
    @discardableResult
    static func create<T: NSManagedObject>(initialization: (T) -> Void = { _ in }) throws -> T {
        let item = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)", into: context) as! T
        initialization(item)
        try synchronize()
        return item
    }
    
    /// 删
    static func delete<T: NSManagedObject>(_ item: T) throws {
        context.delete(item)
        try synchronize()
    }
    
    /// 改
    static func modify(_ execute: () -> Void) throws {
        execute()
        try synchronize()
    }
    
    /// 查
    static func fetch<T: NSManagedObject>(with predicate: NSPredicate?) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
}

extension CoreDataStack {
    static func delete<T: NSManagedObject>(_ type: T.Type, with predicate: NSPredicate?) throws {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0)}
        try synchronize()
    }
    
    static func deleteAll<T: NSManagedObject>(_ type: T.Type) throws {
        try delete(type, with: nil)
    }
    
    static func fetchOne<T: NSManagedObject>(with predicate: NSPredicate) throws -> T? {
        try fetch(with: predicate).first
    }
    
    static func fetchAll<T: NSManagedObject>() throws -> [T] {
        try fetch(with: nil)
    }
}
