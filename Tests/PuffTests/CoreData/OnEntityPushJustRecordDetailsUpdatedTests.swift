//
//  OnEntityPushJustRecordDetailsUpdatedTests.swift
//  PuffTests
//
//  Created by Jaanus Siim on 27/11/2018.
//

import XCTest
@testable import Puff
@testable import PuffCoreData
import CloudKit

@available(OSX 10.12, *)
class OnEntityPushJustRecordDetailsUpdatedTests: XCTestCase {
    private var persistence: Persistence!
    private var serialization: CoreDataSerialization<Survivor>!

    override func setUp() {
        persistence = Persistence.inMemoryPersistence()
        serialization = CoreDataSerialization<Survivor>(context: persistence.mainContext, deserializeUpdatesRecordDetailsOnly: true)
    }

    func testOnlyRecordDetailsTouched() {
        // Idea is, that after push local entity may be updated. In this case deserialization should not override local
        // data with details pushed. Just update record details and let oher processes initiate new entity push
        
        let survivor: Survivor = persistence.mainContext.insertEntity()
        survivor.recordName = "test-record-name"
        survivor.name = "Jake"
        survivor.survival = NSNumber(value: 2)
        survivor.cannotUseFightingArts = true
        
        // record from data push response
        let record = CKRecord(recordType: Survivor.entityName, recordID: CKRecord.ID(recordName: "test-record-name"))
        record["name"] = "Pushed name"
        record["survial"] = NSNumber(value: 1)
        record["cannotUseFightingArts"] = NSNumber(value: false)
        
        let deserialized = serialization.deserialize(records: [record]).first
        XCTAssertNotNil(deserialized)
        XCTAssertNotNil(deserialized?.recordData)
        XCTAssertEqual("Jake", deserialized?.name)
        XCTAssertEqual(NSNumber(value: 2), deserialized?.survival)
        XCTAssertEqual(true, deserialized?.cannotUseFightingArts)
    }
}
