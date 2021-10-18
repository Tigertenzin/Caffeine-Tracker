//
//  CaffeineTrackerApp.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import SwiftUI
import HealthKit
import CoreData
import os
import UserNotifications

@main
struct CaffeineTrackerApp: App {
    let persistenceController = PersistenceController.shared
//    let container = NSCustomPersistentContainer(name: "CaffeineTracker")
    
    var body: some Scene {
        WindowGroup {
            AppOverView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(AppUserDefaults.shared)
        }
    }
}
