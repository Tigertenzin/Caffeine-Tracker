//
//  NotificationSettingsView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/24/20.
//

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var userAppDefualts: AppUserDefaults
    
    @State var doNotifications = false
    @State var notificationTime = Date()
    
    var body: some View {
        List {
            Section(footer: Text("You can choose a time to get daily notifications about logging Caffeine.")) {
                Toggle(isOn: $doNotifications) {
                    Text("Daily Notifications")
                }
                .onChange(of: doNotifications) { newValue in
                    userAppDefualts.hasNotifications = self.doNotifications
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    
                    // Set the deafult time for notifications
                    var dateComponents = DateComponents()
                    dateComponents.hour = 8
                    dateComponents.minute = 30
                    notificationTime = Calendar.current.date(from: dateComponents) ?? Date()
                    UserDefaults.standard.set(self.notificationTime, forKey: "notificationTime")
                    
                    // set notification if turned on, clear all notificaionts if turned off
                    if userAppDefualts.hasNotifications {
                        createReminder(date: notificationTime)
                    } else {
                        deleteReminder()
                    }
                }
            }
            
            if self.doNotifications {
                Section {
                    DatePicker(selection: $notificationTime, displayedComponents: .hourAndMinute) {
                        Text("Select notification time")
                    }
                    .onChange(of: notificationTime) { newValue in
                        UserDefaults.standard.set(self.notificationTime, forKey: "notificationTime")
                        
                        // set notification if turned on, clear all notificaionts if turned off
                        if userAppDefualts.hasNotifications {
                            createReminder(date: notificationTime)
                        } else {
                            deleteReminder()
                        }
                    }
                }
            }
            
            #if DEBUG
            Section(header: Text("Testing")) {
                Button("Request Permission") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
                Text(userAppDefualts.hasNotifications ? "Yes" : "No")
                
                Button("Initiate a test notification") {
                    createReminder(date: notificationTime)
                }
            }
            #endif
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Notifications")
        .onAppear() {
            self.doNotifications = userAppDefualts.hasNotifications
            self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as! Date
        }
    }
}


func createReminder(date: Date) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Success")
          //To add badgeNumber
//          UIApplication.shared.applicationIconBadgeNumber = 1 //(Integer Value)
          
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //remove all pending notification requests that are already scheduled before adding the request.
    
    let content = UNMutableNotificationContent()
    content.title = "Daily Tracking Reminder"
    content.body = "Don't forget to track your daily caffeine intake!"
    content.sound = UNNotificationSound.default //you can play with it
    
    var dateComponents = DateComponents()
    dateComponents.hour = Calendar.current.component(.hour, from: date)
    dateComponents.minute = Calendar.current.component(.minute, from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    print("notification request complete")
}

func deleteReminder() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Success")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //remove all pending notification requests that are already scheduled before adding the request.
    print("cleared all pending notifications")
}
