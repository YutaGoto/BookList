//
//  CoreDataStack.swift
//  BookList
//
//  Created by PC006 on 4/29/16.
//  Copyright © 2016 YutaGoto. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let context:NSManagedObjectContext
    
    let appDocumentDirURL: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)
        
        return urls.last!
    }()
    
    init() {
        let bundle = NSBundle.mainBundle()
        guard let modelURL = bundle.URLForResource("BookListModel", withExtension: "momd") else {
            fatalError()
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError()
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
    
    func addPersistentStoreWithCompletionHandler(completionHandler: (()->Void)?) {
        
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        dispatch_async(backgroundQueue) {
            let dirURL = self.appDocumentDirURL
            let storeURL = dirURL.URLByAppendingPathComponent("BookList.sqlite")
            
            do {
                let coordinator = self.context.persistentStoreCoordinator!
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
                completionHandler?()
            } catch let error as NSError {
                fatalError("\(error)")
            }
        }
    }
    
    func saveContext() throws {
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("\(error)")
                throw error
            }
        }
    }
    
}
