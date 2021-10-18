//
//  NSPersistentContainer.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 11/3/20.
//

import Foundation
import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.CaffeineTracker")
        storeURL = storeURL?.appendingPathComponent("CaffeineTracker.sqlite")
        return storeURL!
    }

} 
