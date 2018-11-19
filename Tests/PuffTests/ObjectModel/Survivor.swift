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
import Puff
import PuffSerialization
import PuffCoreData

@objc(Survivor)
internal class Survivor: NSManagedObject, RemoteRecord, Syncable {    
    @NSManaged var cannotUseFightingArts: Bool
    @NSManaged var name: String?
    @NSManaged var survival: NSNumber?
    
    @NSManaged var recordName: String?
    @NSManaged var recordData: Data?
    
    @NSManaged var attributes: Attributes?
    @NSManaged var syncStatus: SyncStatus?
    
    @NSManaged var disorders: Set<Disorder>?
}
