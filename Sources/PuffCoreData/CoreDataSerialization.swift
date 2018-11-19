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

import CloudKit
import CoreData

#if canImport(PuffSerialization)
import PuffSerialization
#endif
#if canImport(PuffLogger)
import PuffLogger
#endif

@available(OSX 10.12, *)
public class CoreDataSerialization<R: RemoteRecord & NSManagedObject>: RecordSerialization<R> {
    private let context: NSManagedObjectContext
    public init(context: NSManagedObjectContext) {
        self.context = context
        
        super.init()
    }
    
    public override func serialize(records: [R]) -> [CKRecord] {
        return records.map({ serialize(entity: $0) })
    }
    
    public override func deserialize(records: [CKRecord]) -> [R] {
        var deserialized = [R]()
        context.performAndWait {
            let names = records.map({ $0.recordID.recordName })
            let existing: [R] = context.fetch(with: names)
            for record in records {
                let saved: R = existing.first(where: { $0.recordName == record.recordID.recordName }) ?? context.insertEntity()
                load(record: record, into: saved)
                deserialized.append(saved)
            }
        }
        
        return deserialized
    }
    
    private func load(record: CKRecord, into modified: R) {
        var local = modified
        for (name, attribute) in R.entity().attributesByName {
            if name == "recordName" {
                local.recordName = record.recordID.recordName
                continue
            }
            
            if name == "recordData" {
                local.recordData = archive(record: record)
                continue
            }
            
            switch attribute.attributeType {
            case .stringAttributeType, .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .booleanAttributeType:
                local.setValue(record[name], forKey: name)
            default:
                let message = "Unhandled attribute type: \(attribute.attributeType)"
                assertionFailure(message)
                Logging.log(message)
            }
        }
        
        for (name, relationship) in R.entity().relationshipsByName {
            guard let reference = record[name] as? CKRecord.Reference else {
                continue
            }
            
            guard let destination = relationship.destinationEntity else {
                continue
            }
            
            guard destination.properties.first(where: { $0.name == PuffSystemAttributeRecordName }) != nil else {
                continue
            }

            guard let entity = context.fetchEntity(named: destination.name!, withRecordName: reference.recordID.recordName) else {
                Logging.log("No location destination fpr \(relationship.name) named \(reference.recordID.recordName)")
                continue
            }
            
            local.setValue(entity, forKey: name)
        }
    }
    
    private func serialize(entity: R) -> CKRecord {
        let record: CKRecord
        if let existing = unarchiveRecord(entity: entity) {
            record = existing
        } else if let name = entity.recordName {
            record = CKRecord(recordType: R.entityName, recordID: CKRecord.ID(recordName: name))
        } else {
            record = CKRecord(recordType: R.entityName)
        }
        
        for (name, attribute) in entity.entity.attributesByName {
            if PuffSystemAttributes.contains(name) {
                continue
            }
            
            switch attribute.attributeType {
            case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
                record[name] = entity.value(forKey: name) as? NSNumber
            case .stringAttributeType:
                record[name] = entity.value(forKey: name) as? String
            case .booleanAttributeType:
                record[name] = NSNumber(booleanLiteral: entity.value(forKey: name) as? Bool ?? attribute.defaultValue as? Bool ?? false)
            default:
                assertionFailure()
                print("Unhandled attribute type: \(attribute.attributeType)")
            }
        }
        
        for (name, _) in entity.entity.relationshipsByName {
            guard let synced = entity.value(forKey: name) as? RemoteRecord else {
                continue
            }
            
            record[name] = synced.referenceRepresentation(action: .none)
        }
        
        return record
    }
    
    private func unarchiveRecord(entity: RemoteRecord) -> CKRecord? {
        guard let data = entity.recordData else {
            return nil
        }
        
        let coder = NSKeyedUnarchiver(forReadingWith: data)
        coder.requiresSecureCoding = true
        return CKRecord(coder: coder)
    }
}
