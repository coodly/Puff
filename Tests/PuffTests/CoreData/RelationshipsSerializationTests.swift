//
//  RelationshipsSerializationTests.swift
//  PuffTests
//
//  Created by Jaanus Siim on 18/11/2018.
//

import XCTest
@testable import Puff
@testable import PuffCoreData
import CloudKit

@available(OSX 10.12, iOS 10, *)
class RelationshipsSerializationTests: XCTestCase {
    private var persistence: Persistence!
    private var survivorSerialization: CoreDataSerialization<Survivor>!

    override func setUp() {
        super.setUp()

        persistence = Persistence.inMemoryPersistence()
        survivorSerialization = CoreDataSerialization<Survivor>(context: persistence.mainContext)
    }
    
    func testAttributesRelationshipSerialized() {
        let survivor: Survivor = persistence.mainContext.insertEntity()
        let attributes: Attributes = persistence.mainContext.insertEntity()
        
        survivor.attributes = attributes
        attributes.recordName = "attributes-for-jack"
        
        let serializedSurvivor = survivorSerialization.serialize(records: [survivor]).first
        
        XCTAssertNotNil(serializedSurvivor)
        
        let attributesReference = serializedSurvivor?["attributes"] as? CKRecord.Reference
        XCTAssertNotNil(attributesReference)
        XCTAssertEqual("attributes-for-jack", attributesReference?.recordID.recordName)
    }
    
    func testOnDeserializationReferenceRelationshipCreated() {
        let attributes: Attributes = persistence.mainContext.insertEntity()
        attributes.recordName = "attributes-for-jack"
        attributes.accuracy = NSNumber(value: 12)

        let record = CKRecord(recordType: Survivor.entityName)
        record["attributes"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: "attributes-for-jack"), action: .none)
        record["name"] = "Jack"
        
        let survivor = survivorSerialization.deserialize(records: [record]).first
        XCTAssertNotNil(survivor)
        XCTAssertNotNil(survivor?.attributes)
        XCTAssertEqual(12, survivor?.attributes?.accuracy.intValue ?? 0)
    }

    func testNoLocalDataForReference() {
        let record = CKRecord(recordType: Survivor.entityName)
        record["attributes"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: "attributes-for-jack"), action: .none)
        record["name"] = "Jack"
        
        let survivor = survivorSerialization.deserialize(records: [record]).first
        XCTAssertNotNil(survivor)
        XCTAssertNil(survivor?.attributes)
    }
    
    func testToManyRelationshipsDeserialization() {
        let disorderNames = [0, 1, 2].map({ "disorder-\($0)" })
        disorderNames.forEach() {
            name in
            
            let disorder: Disorder = persistence.mainContext.insertEntity()
            disorder.recordName = name
        }
        
        let record = CKRecord(recordType: Survivor.entityName)
        record["disorders"] = disorderNames.map({ CKRecord.Reference(recordID: CKRecord.ID(recordName: $0), action: .none) })
        
        let survivor = survivorSerialization.deserialize(records: [record]).first
        XCTAssertNotNil(survivor)
        XCTAssertNotNil(survivor?.disorders)
        XCTAssertEqual(disorderNames.sorted(), survivor?.disorders?.compactMap({ $0.recordName }).sorted())
    }
}
