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

import CoreData
@testable import PuffCoreData

internal protocol Syncable: class {
    var recordName: String? { get set }
    var recordData: Data? { get set }
    
    var syncStatus: SyncStatus? { get set }
    func markSyncNeeded(_ needed: Bool)
    func markSyncFailed(_ failed: Bool)
}

extension Syncable where Self: NSManagedObject {
    func markSyncNeeded(_ needed: Bool = true) {
        status.syncNeeded = needed
    }
    
    func markSyncFailed(_ failed: Bool) {
        status.syncFailed = failed
    }
    
    private var status: SyncStatus {
        if let existing = syncStatus {
            return existing
        }
        
        let saved: SyncStatus = managedObjectContext!.insertEntity()
        syncStatus = saved
        return saved
    }
}
