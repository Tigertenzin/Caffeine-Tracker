//
//  NewFavoriteSheet.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/17/20.
//

import SwiftUI
import Combine

struct NewFavoriteSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var categoryList: FetchedResults<Category>
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var FavoriteList: FetchedResults<Favorite>
    
    @State var amountString = "0"
    @State var name = ""
    @State var selectedCategory = 1
    @State var showingAlert = false
    @State var showingDatePicker = false
    
    var amountDouble: Double? {
        let trialAmount = Double(amountString)
        return trialAmount
    }
    
    var body: some View {
        NavigationView {
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
            .navigationBarTitle("Add Favorite" )
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                        Label("Cancel", systemImage: "xmark.circle.fill")
                    }
                }
                #endif
                ToolbarItem(placement: .navigationBarTrailing) {
                    if amountDouble != nil {
                        Button(action: {
                            addItem()
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    } else {
                        Button(action: {
                            self.showingAlert = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid Amount"), message: Text("You entered an invalid number as the amount. Please try again"), dismissButton: .default(Text("Done")))
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Favorite(context: viewContext)
            newItem.id = UUID()
            newItem.name = self.name
            newItem.category = categoryList[selectedCategory].name
            newItem.amount = Double(amountString)!

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

struct NewFavoriteSheet_Previews: PreviewProvider {
    static var previews: some View {
        NewFavoriteSheet()
    }
}
