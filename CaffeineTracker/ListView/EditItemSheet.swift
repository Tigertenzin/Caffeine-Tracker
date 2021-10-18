//
//  EditItemSheet.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 9/28/20.
//

import SwiftUI
import Combine

struct EditItemSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var categoryList: FetchedResults<Category>
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var FavoriteList: FetchedResults<Favorite>
    
    
    @State var edittedItem: Item
    
    @State var amountString = "0"
    @State var name = ""
    @State var oldDate = Date()
    @State var date = Date()
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
            
            Section {
                Button(action: {self.showingDatePicker.toggle()}) {
                    HStack{
                        Text("Select a date:")
                        Spacer()
                        Text("\(date, formatter: itemFormatter)")
                    }
                }
                if self.showingDatePicker {
                    DatePicker("Select a date", selection: $date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(maxHeight: 400)
                }
            }
            .animation(.default)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Edit Item")
        .alert(isPresented: $notValidSavable) {
            Alert(title: Text("Error Saving Changes"), message: Text("This item wasn't created in this App and therefore cannot change existing items in the Health App."), dismissButton: .default(Text("Done")))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.notValidSavable = HealthDataQuery.shared.fetchAndDeleteCaffeine(sampleDate: self.oldDate)
                    if self.notValidSavable == false {
                        // If we are able to delete the old item from Healthkit (validSavable == true):
                        // Proceed with creating a new entry with the changes. Otherwise, present an alert.
                        HealthDataQuery.shared.writeHealthDate(milligram: Double(amountString)!, date: self.date)
                        
                        edittedItem.id = UUID()
                        edittedItem.name = self.name
                        edittedItem.category = categoryList[selectedCategory].name
                        edittedItem.timestamp = self.date
                        edittedItem.amount = Double(amountString)!

                        do {
                            try viewContext.save()
                        } catch {
                            // Replace this implementation with code to handle the error appropriately.
                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear() {
            self.name = edittedItem.name ?? "N/A"
            self.oldDate = edittedItem.timestamp ?? Date()
            self.date = edittedItem.timestamp ?? Date()
            self.categoryName = edittedItem.category ?? "Unknown category"
            self.amountString = String(edittedItem.amount)
            for category_j in 0..<categoryList.count {
                if categoryList[category_j].name == categoryName {
                    selectedCategory = category_j
                }
            }
        }
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
