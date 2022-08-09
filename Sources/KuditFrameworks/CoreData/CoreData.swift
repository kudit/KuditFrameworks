//
//  CoreDataManager.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 10/20/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

// TODO: figure out how to easily sync between iOS devices via iCloud

/*
Usage:

// Create a container:
let coreDataManager = NSPersistentContainer(appGroupName: "group.com.kudit.Tracker")
// or
let coreDataManager = NSPersistentContainer(modelName: "ReferenceData", isReferenceData: true)

// get the main context:
let mainContext = coreDataManager.viewContext

// save the context data
coreDataManager.saveContext()

// Add to applicationWillTerminate to save on exit:
coreDataManager.saveContext()

*/

import Foundation
import CoreData

public extension NSPersistentContainer {
    private var appGroupName: String? {
        get { return self.getAssociatedObject(key: #function) as? String }
        set { self.setAssociatedObject(newValue as AnyObject, forKey: #function) }
    }
    private var isReferenceData: Bool {
        get {
            if let value = self.getAssociatedObject(key: #function) {
                return value as! Bool
            }
            return false
        }
        set { self.setAssociatedObject(newValue as AnyObject, forKey: #function) }
    }

    private var coreDataStoreURL: URL {
        // figure out the appropirate URL to store the data files based on the reference data and if an app group name is available
        let storeDirectory: URL
        do {
            if isReferenceData {
                // store in Caches directory.
                storeDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            } else if let appGroupName = appGroupName {
                // use the shared appGroupStore so that the watchkit extention can also use
                storeDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)!
            } else {
                // store in local user documents directory
                storeDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            }
        } catch {
            fatalError("Error fetching core data store URL: \(error)")
        }
        return storeDirectory.appendingPathComponent("\(name).sqlite")
    }

    convenience init(bundle: Bundle = Bundle.main, modelName: String = "Model", appGroupName: String? = nil, isReferenceData: Bool = false) {
        let modelURL = bundle.url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        self.init(name: modelName, managedObjectModel: managedObjectModel)
        
        // store virtual properties
        self.appGroupName = appGroupName
        self.isReferenceData = isReferenceData
        
        // go ahead and configure and load persistent stores
        self.persistentStoreDescriptions = [NSPersistentStoreDescription(url: coreDataStoreURL)]
        self.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else if (appGroupName != nil) {
                // force data to refresh from store more often (for improved tracker-watch synchronization)
                self.viewContext.stalenessInterval = 1
            }
        })
    }
    
    /// to speed up large deletes, just delete the store (hopefully not mingling user and fetchable data).  The persistent container should be re-created after this is done to reset.
    func delete() {
        synchronized(self) { // prevent thread problems by getting a lock
            print("KCDM: Deleting and resetting entire store for model \(name)")

            // remove old notifications
            NotificationCenter.default.removeObserver(self)
            // reset the main context
            viewContext.reset()
    
            // remove the store file data
            do {
                for store in persistentStoreCoordinator.persistentStores {
                    try persistentStoreCoordinator.remove(store)
                }
                if FileManager.default.fileExists(atPath: coreDataStoreURL.path) {
                    try FileManager.default.removeItem(atPath: coreDataStoreURL.path)
                }
            } catch {
                fatalError("Could not delete persistent store.")
            }
        }
    }
    
    // MARK: - Core Data update notification handlers (hopefully no longer necessary with the Persistent Container
}

public extension NSManagedObjectContext {
    // MARK: - Core Data Saving support
    func saveIfDirty() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
