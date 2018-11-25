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

import XCTest
@testable import Puff
@testable import PuffCoreData
import CloudKit

@available(OSX 10.12, *)
class SimpleValuesConverasionTests: XCTestCase {
    private var persistence: Persistence!
    private var serialization: CoreDataSerialization<Survivor>!
    private var existing: Survivor!
    
    override func setUp() {
        super.setUp()

        persistence = Persistence.inMemoryPersistence()
        serialization = CoreDataSerialization<Survivor>(context: persistence.mainContext)
        
        existing = persistence.mainContext.insertEntity()
        existing.recordName = "existing-1"
        existing.name = "My name"
        existing.survival = NSNumber(value: 3)
    }
    
    func testSurvivorDetailsSerialization() {
        let survivor: Survivor = persistence.mainContext.insertEntity()
        survivor.name = "Jack"
        survivor.survival = NSNumber(value: 1)
        survivor.cannotUseFightingArts = false
        
        let record = serialization.serialize(records: [survivor]).first
        XCTAssertNotNil(record)
        
        XCTAssertEqual("Survivor", record?.recordType)
        XCTAssertEqual("Jack", record?["name"])
        XCTAssertEqual(NSNumber(value: 1), record?["survival"])
        XCTAssertEqual(NSNumber(booleanLiteral: false), record?["cannotUseFightingArts"])
    }
    
    func testLoadRecordFields() {
        let record = CKRecord(recordType: Survivor.entityName)
        record["name"] = "Mick"
        record["survival"] = NSNumber(value: 12)
        record["cannotUseFightingArts"] = NSNumber(value: true)
        
        let survivor = serialization.deserialize(records: [record]).first
        XCTAssertNotNil(survivor)
        XCTAssertEqual("Mick", survivor?.name)
        XCTAssertEqual(12, survivor?.survival?.intValue)
        XCTAssertTrue(survivor?.cannotUseFightingArts ?? false)
        XCTAssertNotNil(survivor?.recordName)
        XCTAssertNotNil(survivor?.recordData)
    }

    func testExistingUpdated() {
        let record = CKRecord(recordType: Survivor.entityName, recordID: CKRecord.ID(recordName: "existing-1"))
        record["name"] = "Mick 2"
        record["survival"] = NSNumber(value: 121)
        record["cannotUseFightingArts"] = NSNumber(value: true)
        
        let survivor = serialization.deserialize(records: [record]).first
        XCTAssertNotNil(survivor)
        persistence.mainContext.refresh(existing, mergeChanges: true)
        
        XCTAssertEqual(existing, survivor)
        XCTAssertEqual(existing.recordName, "existing-1")
        XCTAssertEqual("Mick 2", existing.name)
        XCTAssertEqual(121, existing.survival?.intValue)
        XCTAssertTrue(existing.cannotUseFightingArts)
        XCTAssertNotNil(existing.recordName)
        XCTAssertNotNil(existing.recordData)
    }
    
    func testLocalDataNotRemovedOnPartialRecordUpdate() {
        let survivor: Survivor = persistence.mainContext.insertEntity()
        
        survivor.recordName = "survivor-one"
        survivor.name = "Uunp"
        survivor.survival = NSNumber(value: 7)
        
        let record = CKRecord(recordType: Survivor.entityName, recordID: CKRecord.ID(recordName: "survivor-one"))
        record["name"] = "Mick 2"
        
        let deserialized = serialization.deserialize(records: [record]).first
        XCTAssertNotNil(deserialized)
        XCTAssertEqual("survivor-one", deserialized?.recordName)
        XCTAssertEqual("Mick 2", deserialized?.name)
        XCTAssertEqual(NSNumber(value: 7), deserialized?.survival)
    }

    func testTransientPropertyNotSerializes() {
        let survivor: Survivor = persistence.mainContext.insertEntity()
        
        survivor.recordName = "survivor-one"
        survivor.name = "Uunp"
        survivor.survival = NSNumber(value: 7)
        survivor.touchedAt = Date()
        
        let serialized = serialization.serialize(records: [survivor]).first
        XCTAssertNotNil(serialized)
        XCTAssertNil(serialized?["touchedAt"])
    }
}
