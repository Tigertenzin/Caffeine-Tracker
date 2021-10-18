//
//  EditFavoritesView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/17/20.
//

import SwiftUI
import Combine

struct EditFavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var categoryList: FetchedResults<Category>
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var FavoriteList: FetchedResults<Favorite>
    
    
    @State var editFavorite: Favorite
    
    @State var amountString = "0"
    @State var name = ""
    @State var categoryName = ""
    @State var selectedCategory = 1
    @State var showingAlert = false
    @State var showingDatePicker = false
    @State var notValidSavable = false
    
    var body: some View {
        List{
            Section(header: Text("Name and Category")) {
                TextField("Name of entry", text: $name)
                Picker(selection: $selectedCategory, label: Text("Category")) {
                    ForEach(0 ..< categoryList.count) {
                        Text(categoryList[$0].name ?? "Other")
                    }
                }
            }
            
            Section{
                Text("Enter amount below: ")
                TextField("Total number of people", text: $amountString)
                    .keyboardType(.numberPad)
                    .onReceive(Just(amountString)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.amountString = filtered
                        }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Edit Favorite")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editFavorite.id = UUID()
                    editFavorite.name = self.name
                    editFavorite.category = categoryList[selectedCategory].name
                    editFavorite.amount = Double(amountString)!

                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear() {
            self.name = editFavorite.name ?? "N/A"
            self.categoryName = editFavorite.category ?? "Unknown category"
            self.amountString = String(editFavorite.amount)
            for category_j in 0..<categoryList.count {
                if categoryList[category_j].name == categoryName {
                    selectedCategory = category_j
                }
            }
        }
    }
}
