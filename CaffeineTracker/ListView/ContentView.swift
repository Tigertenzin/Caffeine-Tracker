//
//  ContentView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import SwiftUI
import CoreData
import HealthKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var itemsCDList: FetchedResults<Item>
    
    @State var caffeineItems = [HKQuantitySample]()
    @State var showAddSheet = false
    @State var showDeleteAlert = false
    @State var displayDate = Date()
    
    var body: some View {
        NavigationView {
                ZStack {
                List {
                    Section {
                        VStack{
                            AmountGauge(displayDate: self.$displayDate)
                                .padding([.horizontal])
                                .animation(.default)
                        }
                        
                        HStack{
                            Button(action: {
                                self.displayDate = NSCalendar.current.date(byAdding: .day, value: -1, to: displayDate) ?? Date()
                            }) {
                                Image(systemName: "chevron.left.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Spacer()
                            Text("\(displayDate, formatter: itemFormatter2)")
                            Spacer()
                            
                            Button(action: {
                                self.displayDate = NSCalendar.current.date(byAdding: .day, value: +1, to: displayDate) ?? Date()
                            }) {
                                Image(systemName: "chevron.right.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    
                    Section(header: Text("List of Entries")) {
                        ForEach(itemsCDList, id: \.id) { item in
                            NavigationLink(destination: EditItemSheet(edittedItem: item, amountString: String(item.amount))) {
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text("\(item.name ?? "Unknown name")")
                                            .font(Calendar.current.isDate(item.timestamp ?? Date.tomorrow, equalTo: Date(), toGranularity: .day) ? Font.headline.weight(.bold) : Font.headline.weight(.regular))
                                        Text("\(item.category ?? "Unknown category")")
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(String(format: "%.2f", item.amount))mg")
                                            .font(Calendar.current.isDate(item.timestamp ?? Date.tomorrow, equalTo: Date(), toGranularity: .day) ? Font.headline.weight(.bold) : Font.headline.weight(.regular))
                                        Text("\(item.timestamp ?? Date(), formatter: itemFormatter)")
                                            .font(.footnote)
                                    }
                                }
                                .padding(4)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Entries" )
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("Deletion Notice"), message: Text("At least 1 item being deleted was not created in this app and therefore cannot be deleted from the Health App."), dismissButton: .default(Text("Done")))
                }
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
                
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        Button(action: {
                            self.showAddSheet.toggle()
                        }, label: {
                            Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                        })
                        .background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {self.loadCaffeineList()}) {
            AddItemSheet()
                .accentColor(self.userAppDefaults.themeColor)
        }
        .onAppear() {
            self.loadCaffeineList()
        }
//        .onReceive(self.$caffeineItems, perform: {
//            self.loadCaffeineList()
//        })
    }
    
    func loadCaffeineList() {
        HealthDataQuery.shared.fetchHealthData(completion: {caffeineRetrieved in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.caffeineItems = caffeineRetrieved
            }
        })
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                self.showDeleteAlert = HealthDataQuery.shared.fetchAndDeleteCaffeine(sampleDate: itemsCDList[index].timestamp ?? Date())
                viewContext.delete(itemsCDList[index])
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

private let itemFormatter2: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
