//
//  ManyToManyRelationshipsSerializationTests.swift
//  PuffTests
//
//  Created by Jaanus Siim on 19/11/2018.
//

import XCTest
@testable import Puff
@testable import PuffCoreData
import CloudKit

@available(OSX 10.12, iOS 10, *)
class ManyToManyRelationshipsSerializationTests: XCTestCase {
    private var persistence: Persistence!
    private var survivorSerialization: CoreDataSerialization<Survivor>!

    override func setUp() {
        persistence = Persistence.inMemoryPersistence()
        survivorSerialization = CoreDataSerialization<Survivor>(context: persistence.mainContext)
    }
    
    func testToManyReferencesCreated() {
        let survivor: Survivor = persistence.mainContext.insertEntity()
        let disorders = [
            createDisorder(recordName: "disorder-1"),
            createDisorder(recordName: "disorder-2"),
            createDisorder(recordName: "disorder-3")
        ]
        survivor.disorders = Set(disorders)
        
        let serialized = survivorSerialization.serialize(records: [survivor]).first
        
        XCTAssertNotNil(serialized)
        let disorderReferences = serialized?["disorders"] as? [CKRecord.Reference]
        XCTAssertNotNil(disorderReferences)
        
        XCTAssertEqual(["disorder-1", "disorder-2", "disorder-3"], (disorderReferences ?? []).map({ $0.recordID.recordName }).sorted())
    }

    private func createDisorder(recordName: String) -> Disorder {
        let created: Disorder = persistence.mainContext.insertEntity()
        created.recordName = recordName
        created.name = "Disorder \(recordName)"
        return created
    }
}
