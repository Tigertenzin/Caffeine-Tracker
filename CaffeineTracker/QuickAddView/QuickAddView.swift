//
//  QuickAddView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/16/20.
//

import SwiftUI
import CoreData
import HealthKit

struct QuickAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var favoritesList: FetchedResults<Favorite>
    
    @State var caffeineItems = [HKQuantitySample]()
    @State var showAddSheet = false
    
    @State var displayDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack{
                        AmountGauge(displayDate: $displayDate)
                            .padding([.horizontal])
                            .animation(.default)
                    }
                }
                
                Section {
                    ForEach(favoritesList, id: \.id) { favorite in
                        Button(action: {quickAddItem(name: favorite.name ?? "Unknown name", categoryName: favorite.category ?? "Unknown Category", amount: favorite.amount) }) {
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("\(favorite.name ?? "Unknown name")")
                                    Text("\(favorite.category ?? "Unknown category")")
                                        .font(.footnote)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(String(format: "%.2f", favorite.amount))mg")
                                }
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(self.userAppDefaults.themeColor)
                                    .imageScale(.large)
                            }
                            .padding(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Quick Add" )
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                #endif
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {self.showAddSheet.toggle()}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {self.loadCaffeineList()}) {
                NewFavoriteSheet()
                    .accentColor(self.userAppDefaults.themeColor)
            }
        }
        .onAppear() {
            self.loadCaffeineList()
        }
    }
    func loadCaffeineList() {
        HealthDataQuery.shared.fetchHealthData(completion: {caffeineRetrieved in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.caffeineItems = caffeineRetrieved
            }
        })
    }
    
    func quickAddItem(name: String, categoryName: String, amount: Double) {
        let sampleDate = Date()
        HealthDataQuery.shared.writeHealthDate(milligram: amount, date: sampleDate)
        
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        newItem.category = categoryName
        newItem.timestamp = sampleDate
        newItem.amount = amount
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewContext.delete(favoritesList[index])
            }

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

struct QuickAddView_Previews: PreviewProvider {
    static var previews: some View {
        QuickAddView()
    }
}
