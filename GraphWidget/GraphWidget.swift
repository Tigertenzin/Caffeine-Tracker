//
//  GraphWidget.swift
//  GraphWidget
//
//  Created by Thomas Tenzin on 10/27/20.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    var managedObjectContext : NSManagedObjectContext
    
    init(context : NSManagedObjectContext) {
        self.managedObjectContext = context
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct GraphWidgetEntryView : View {
    
    var entry: Provider.Entry
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var itemsCDList: FetchedResults<Item>
    
    var body: some View {
        VStack{
            Text("7 Day Graphs")
//            Text("Found \(itemsCDList.count) items")
            Text(entry.date, style: .time)
        }
    }
}

@main
struct GraphWidget: Widget {
    let kind: String = "GraphWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: persistentContainer.viewContext)) { entry in
            GraphWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Graph Widget")
        .description("Display bar graphs for caffeine intake in the past 7 days.")
    }
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSCustomPersistentContainer(name: "CaffeineTracker")
    //    let storeURL = URL.storeURL(for: "group.com.seannagle.ipostmaster", databaseName: "iPostMaster")
    //    let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    //    container.persistentStoreDescriptions = [storeDescription]
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return container
    }()
}

struct GraphWidget_Previews: PreviewProvider {
    static var previews: some View {
        GraphWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

