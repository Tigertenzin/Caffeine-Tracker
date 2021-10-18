//
//  Setting_DailyGoalView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/17/20.
//

import SwiftUI
import Combine

struct Setting_DailyGoalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @State var amountString = "0"
    
    var body: some View {
        List{
            Section{
                Text("Enter new goal/limit below: ")
                TextField("Enter new goal/limit", text: $amountString)
                    .keyboardType(.numberPad)
                    .onReceive(Just(amountString)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.amountString = filtered
                        }
                }
            }
            
            Section(footer: Text("You may need to quit out of the app to see changes. ")){
                Button(action: {userAppDefaults.dailyGoal = Int(amountString) ?? 200}) {
                    Text("Save")
                }
            }
        }
        
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Edit Limit")
        .onAppear() {
            self.amountString = String(userAppDefaults.dailyGoal)
        }
    }
}

struct Setting_DailyGoalView_Previews: PreviewProvider {
    static var previews: some View {
        Setting_DailyGoalView()
    }
}
