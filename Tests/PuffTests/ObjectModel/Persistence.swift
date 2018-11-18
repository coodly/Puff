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
        let survivorDesc = entityDescription(for: Survivor.self)
        
        let survivorName = attribute(named: "name", type: .stringAttributeType)
        let surviorSurvival = attribute(named: "survival", type: .integer32AttributeType)
        let survivorCannotUseFighting = attribute(named: "cannotUseFightingArts", type: .booleanAttributeType, defaulrValue: false)
        
        // Attributes
        let attributesDesc = entityDescription(for: Attributes.self)
        
        let attributeAccuracy = attribute(named: "accuracy", type: .integer32AttributeType, defaulrValue: NSNumber(value: 0), optional: false)
        let attributeEvasion = attribute(named: "evasion", type: .integer32AttributeType, defaulrValue: NSNumber(value: 0), optional: false)
        let attributeLuck = attribute(named: "luck", type: .integer32AttributeType, defaulrValue: NSNumber(value: 0), optional: false)
        
        // SyncStatus
        let localSyncStatusDesc = syncStatusDesc
        
        let syncStatusSyncNeeded = attribute(named: "syncNeeded", type: .booleanAttributeType, defaulrValue: true)
        let syncStatusSyncFailed = attribute(named: "syncFailed", type: .booleanAttributeType, defaulrValue: false)
        
        // Survivor <-> Attributes
        let survivorHasAttributes = oneToOneRelationship(to: attributesDesc, named: "attributes")
        let attributesBelongToSurvivor = oneToOneRelationship(to: survivorDesc, named: "survivor")
        
        // Survivor <-> SyncStatus
        let survivorHasSyncStatus = attachedSyncStatus()
        let syncStatusBelongsToSurvivor = reversedSyncStatusRelationship(to: survivorDesc, named: "statusForSurvivor")
        
        // Attributes <-> SyncStatus
        let attributesHasSyncStatus = attachedSyncStatus()
        let syncStatusBelongsToAttributes = reversedSyncStatusRelationship(to: attributesDesc, named: "statusForAttributes")

        // Entity properties
        survivorDesc.properties = [survivorName, surviorSurvival, survivorCannotUseFighting, recordNameAttribute(), recordDataAttribute(), survivorHasSyncStatus, survivorHasAttributes]
        attributesDesc.properties = [attributeAccuracy, attributeEvasion, attributeLuck, recordNameAttribute(), recordDataAttribute(), attributesHasSyncStatus, attributesBelongToSurvivor]
        localSyncStatusDesc.properties = [syncStatusSyncNeeded, syncStatusSyncFailed, syncStatusBelongsToSurvivor, syncStatusBelongsToAttributes]
        
        model.entities = [survivorDesc, syncStatusDesc, attributesDesc]
        
        return model
    }()
    
    // SyncStatus
    private static let syncStatusDesc: NSEntityDescription = entityDescription(for: SyncStatus.self)
    
    private static func entityDescription<T: NSManagedObject>(for type: T.Type) -> NSEntityDescription {
        let desc = NSEntityDescription()
        desc.name = T.entityName
        desc.managedObjectClassName = T.entityName
        return desc
    }
    
    private static func recordNameAttribute() -> NSAttributeDescription {
        return attribute(named: "recordName", type: .stringAttributeType)
    }
    private static func recordDataAttribute() -> NSAttributeDescription {
        return attribute(named: "recordData", type: .binaryDataAttributeType)
    }

    private static func attribute(named: String, type: NSAttributeType, defaulrValue: Any? = nil, optional: Bool = true) -> NSAttributeDescription {
        let desc = NSAttributeDescription()
        desc.name = named
        desc.attributeType = type
        desc.defaultValue = defaulrValue
        desc.isOptional = optional
        return desc
    }
    
    private static func attachedSyncStatus() -> NSRelationshipDescription {
        let hasSyncStatus = NSRelationshipDescription()
        hasSyncStatus.destinationEntity = syncStatusDesc
        hasSyncStatus.name = "syncStatus"
        hasSyncStatus.deleteRule = .cascadeDeleteRule
        hasSyncStatus.minCount = 0
        hasSyncStatus.maxCount = 1
        
        return hasSyncStatus
    }
    
    private static func reversedSyncStatusRelationship(to desc: NSEntityDescription, named: String) -> NSRelationshipDescription {
        return oneToOneRelationship(to: desc, named: named, deleteRule: .nullifyDeleteRule)
    }
    
    private static func oneToOneRelationship(to desc: NSEntityDescription, named: String, deleteRule: NSDeleteRule = .cascadeDeleteRule) -> NSRelationshipDescription {
        let hasSyncStatus = NSRelationshipDescription()
        hasSyncStatus.destinationEntity = desc
        hasSyncStatus.name = named
        hasSyncStatus.deleteRule = deleteRule
        hasSyncStatus.minCount = 0
        hasSyncStatus.maxCount = 1
        
        return hasSyncStatus
    }
}
