//
//  AppView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import SwiftUI
import HealthKit

struct AppOverView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    @Environment(\.colorScheme) var deviceColorScheme
    
    @State var hasAccessToHealthData = UserDefaults.standard.bool(forKey: "isHealthDataAllowed")
    
    var body: some View {
        AppView()
            .accentColor(self.userAppDefaults.themeColor)
            .environment(\.colorScheme, self.userAppDefaults.themeColorScheme ?? deviceColorScheme)
            .onAppear() {
                // Check if the app has HealthKit access
                if !(self.hasAccessToHealthData) {
                    print("Requesting Health Aceess")
                    HealthDataQuery.shared.authorizeHealthKit()
                }
                // Increment number of app launches
                userAppDefaults.numberOfLaunch += 1
            }
    }
}




struct AppView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        if sizeClass == .compact {
            TabView {
                QuickAddView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Quick Add")
                    }
                
                ContentView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("List")
                    }
                
                StatisticsView()
                    .tabItem {
                        Image(systemName: "chevron.up.circle.fill")
                        Text("Stats")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        } else {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Menu")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
