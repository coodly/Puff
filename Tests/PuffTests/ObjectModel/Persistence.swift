/*
 * Copyright 2018 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import CoreData
@testable import PuffCoreData

@available(OSX 10.12, *)
internal class Persistence {
    internal static func inMemoryPersistence() -> Persistence {
        return Persistence()
    }
    
    internal var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Puffed", managedObjectModel: Persistence.objectModel)
        let config = NSPersistentStoreDescription()
        
        config.type = NSSQLiteStoreType
        container.persistentStoreDescriptions = [config]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
            }
        })
        return container
    }()
    
    private static var objectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        
        // Survivor
        let survivorDesc = NSEntityDescription()
        survivorDesc.name = Survivor.entityName
        survivorDesc.managedObjectClassName = Survivor.entityName
        
        let survivorName = attribute(named: "name", type: .stringAttributeType)
        let surviorSurvival = attribute(named: "survival", type: .integer32AttributeType)
        let survivorCannotUseFighting = attribute(named: "cannotUseFightingArts", type: .booleanAttributeType, defaulrValue: false)
        
        // SyncStatus
        let syncStatusDesc = NSEntityDescription()
        syncStatusDesc.name = SyncStatus.entityName
        syncStatusDesc.managedObjectClassName = SyncStatus.entityName
        
        let syncStatusSyncNeeded = attribute(named: "syncNeeded", type: .booleanAttributeType, defaulrValue: true)
        let syncStatusSyncFailed = attribute(named: "syncFailed", type: .booleanAttributeType, defaulrValue: false)
        
        // Survivor <-> SyncStatus
        let survivorHasSyncStatus = NSRelationshipDescription()
        survivorHasSyncStatus.destinationEntity = syncStatusDesc
        survivorHasSyncStatus.name = "syncStatus"
        survivorHasSyncStatus.deleteRule = .cascadeDeleteRule
        survivorHasSyncStatus.minCount = 0
        survivorHasSyncStatus.maxCount = 1

        let syncStatusBelongsToSurvivor = NSRelationshipDescription()
        syncStatusBelongsToSurvivor.destinationEntity = survivorDesc
        syncStatusBelongsToSurvivor.name = "statusForSurvivor"
        syncStatusBelongsToSurvivor.deleteRule = .nullifyDeleteRule
        syncStatusBelongsToSurvivor.minCount = 0
        syncStatusBelongsToSurvivor.maxCount = 1
        
        // Entity properties
        survivorDesc.properties = [survivorName, surviorSurvival, survivorCannotUseFighting, recordNameAttribute(), recordDataAttribute(), survivorHasSyncStatus]
        syncStatusDesc.properties = [syncStatusSyncNeeded, syncStatusSyncFailed, syncStatusBelongsToSurvivor]
        
        model.entities = [survivorDesc, syncStatusDesc]
        
        return model
    }()
    
    private static func recordNameAttribute() -> NSAttributeDescription {
        return attribute(named: "recordName", type: .stringAttributeType)
    }
    private static func recordDataAttribute() -> NSAttributeDescription {
        return attribute(named: "recordData", type: .binaryDataAttributeType)
    }

    private static func attribute(named: String, type: NSAttributeType, defaulrValue: Any? = nil) -> NSAttributeDescription {
        let desc = NSAttributeDescription()
        desc.name = named
        desc.attributeType = type
        desc.defaultValue = defaulrValue
        return desc
    }
}
