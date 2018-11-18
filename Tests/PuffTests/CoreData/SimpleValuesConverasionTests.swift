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
@testable import PuffCD

@available(OSX 10.12, *)
class SimpleValuesConverasionTests: XCTestCase {
    func testSurvivorDetailsSerialization() {
        let persistence = Persistence.inMemoryPersistence()
        
        let survivor: Survivor = persistence.mainContext.insertEntiry()
        survivor.name = "Jack"
        survivor.survival = NSNumber(value: 1)
        survivor.cannotUseFightingArts = false
        
        let record = survivor.recordRepresentation()
        XCTAssertNotNil(record)
        
        XCTAssertEqual("Survivor", record?.recordType)
        XCTAssertEqual("Jack", record?["name"])
        XCTAssertEqual(NSNumber(value: 1), record?["survival"])
        XCTAssertEqual(NSNumber(booleanLiteral: false), record?["cannotUseFightingArts"])
    }
}
