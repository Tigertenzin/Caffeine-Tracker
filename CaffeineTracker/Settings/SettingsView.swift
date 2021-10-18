//
//  SettingsView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import SwiftUI
import CoreData
import HealthKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var userAppDefualts: AppUserDefaults
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var itemsCDList: FetchedResults<Item>
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)]) var categoryList: FetchedResults<Category>
    
    @State var caffeineItems = [HKQuantitySample]()
    @State var showLoadingAlert = false
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Appearance")) {
                    
                    Picker(selection: $userAppDefualts.themeLightDark, label: Text("App Theme")) {
                        ForEach(0...2, id: \.self) { themeIndex in
                            Text(self.userAppDefualts.themeLightDarkNames[themeIndex])
                        }
                    }
                    
                    HStack {
                        Image(systemName: "circle.lefthalf.fill")
                        Picker(selection: $userAppDefualts.themeIndex, label: Text("App Tint")) {
                            ForEach(0...7, id: \.self) { themeIndex in
                                HStack{
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(self.userAppDefualts.themeColors[themeIndex])
                                        .frame(width: 16, height: 16)
                                    Text(self.userAppDefualts.themeNames[themeIndex])
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("List Settings")) {
                    
                    NavigationLink(destination: FavoritesList()) {
                        HStack{
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(.pink)
                            Text("Edit Favorites")
                        }
                    }
                    
                    HStack{
                        Image(systemName: "folder.circle.fill")
                            .renderingMode(.original)
                        Text("Edit Categories")
                    }
                    
                    NavigationLink(destination: Setting_DailyGoalView()) {
                        HStack{
                            Image(systemName: "star.circle.fill")
                                .renderingMode(.original)
                            Text("Change Daily Goal/Limit: \(userAppDefualts.dailyGoal)")
                        }
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack{
                            Image(systemName: "bell.circle.fill")
                                .renderingMode(.original)
                            Text("Change Daily Notifications")
                        }
                    }
                }
                
                Section(header: Text("Reset data")) {
                    Button(action: {
                        resetFavorites()
                    } ) {
                        Text("Reset favorites")
                    }
                    
                    Button(action: {
                        resetCategories()
                    } ) {
                        Text("Reset categories")
                    }
                }
                
                Section(footer: Text("Resync the app's data with the data stored in the Health App. Creates items in App for every item found in Health (does not overwrite existing items). Note that items that were added from other Apps cannot be deleted from Caffeine Tracker. ")) {
                    VStack{
                        Button(action: {
                            self.showLoadingAlert = true
                            rebuildDatabase()
                            self.showLoadingAlert = false
                        } ) {
                            Text("Resync database with HealthKit")
                        }
                    }
                }
                #if DEBUG
                Section(header: Text("Testing information")) {
                    if userAppDefualts.isSubscribed {
                        Text("Subscription status: True")
                    } else {
                        Text("Subscription status: False")
                    }
                    Text("Number of launches: \(userAppDefualts.numberOfLaunch)")
                    Text("Is Health allowed: \(userAppDefualts.isHealthDataAllowed)")
                    
                    Button(action: {
                            print("\(colorScheme == .light ? "lightImage" : "darkImage")")
                        }) {
                            Text("Test light/dark mode detection")
                        }
                }
                #endif
            }
            .navigationBarTitle("Settings")
            .alert(isPresented: $showLoadingAlert) {
                Alert(title: Text("Loading HealthKit"), message: Text("We are adding your Health data to the app. Please wait a moment, the alert will automatically dismiss when finished."), dismissButton: .default(Text("Done")))
            }
        }
    }

    func loadCaffeineList() {
        HealthDataQuery.shared.fetchHealthData(completion: {caffeineRetrieved in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.caffeineItems = caffeineRetrieved
            }
        })
    }
    
    func rebuildDatabase() {
        self.loadCaffeineList()
        print("Found \(caffeineItems.count) items HealthKit")
        for sampleHK in caffeineItems {
            if itemsCDList.contains(where: { $0.timestamp==sampleHK.endDate && $0.amount==sampleHK.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli))}) {
            } else {
                let newItem = Item(context: viewContext)
                newItem.id = UUID()
                newItem.name = "Imported Item"
                newItem.timestamp = sampleHK.endDate
                newItem.amount = sampleHK.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli))
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        print("finished with \(itemsCDList.count) items in Core Data")
    }
    
    func resetFavorites() {
        print("Function to reset favorites database")
        let newItem = Favorite(context: viewContext)
        newItem.id = UUID()
        newItem.name = "G Fuel"
        newItem.amount = 140.0
        newItem.category = "Energy Drinks"
        do {
            try self.viewContext.save()
        } catch {
            print("Something went wrong...")
        }
    }
    
    func resetCategories() {
        print("Function to reset categories database")
        let defaultCategories = ["Coffee & Espresso", "Tea", "Energy Drinks", "Soft Drinks", "Caffeinated Food", "Over-the-Counter Pills"]
        for category in categoryList {
            viewContext.delete(category)
        }
        for defaultCategory in defaultCategories {
            let newItem = Category(context: viewContext)
            newItem.id = UUID()
            newItem.name = defaultCategory
            do {
                try self.viewContext.save()
            } catch {
                print("Something went wrong...")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
