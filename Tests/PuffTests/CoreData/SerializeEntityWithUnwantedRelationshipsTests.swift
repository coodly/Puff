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
class SerializeEntityWithUnwantedRelationshipsTests: XCTestCase {
    private var persistence: Persistence!
    private var serialization: CoreDataSerialization<Disorder>!
    
    override func setUp() {
        persistence = Persistence.inMemoryPersistence()
        serialization = CoreDataSerialization<Disorder>(context: persistence.mainContext)
    }

    func testRelationshipToSurvuvorNotSerialized() {
        let survivorNames = [1, 2, 3, 4].map({ "survivor-\($0)" })
        let survivors: [Survivor] = survivorNames.map() {
            name in
            
            let created: Survivor = persistence.mainContext.insertEntity()
            created.recordName = name
            return created
        }
        let disorder: Disorder = persistence.mainContext.insertEntity()
        disorder.survivors = Set(survivors)
        
        XCTAssertEqual(4, disorder.survivors!.count)
        
        let serialized = serialization.serialize(records: [disorder]).first
        
        XCTAssertNotNil(serialized)
        XCTAssertNil(serialized?["survivors"])
    }
}
