//
//  AppUserDefaults.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import Foundation
import Combine
import SwiftUI

public class AppUserDefaults: ObservableObject {
    public static let shared = AppUserDefaults(themeIndex: 0)
    
    @Published var themeIndex: Int {
        didSet {
            UserDefaults.standard.set(themeIndex, forKey: "themeIndex")
        }
    }
    
    @Published var themeLightDark: Int {
        didSet {
            UserDefaults.standard.set(themeLightDark, forKey: "themeLightDark")
        }
    }
    
    public var themeNames = ["Red", "Blue", "Green", "Yellow", "Orange", "Purple",  "Pink", "Gray"]
    public var themeColors = [Color.red, Color.blue, Color.green, Color.yellow, Color.orange, Color.purple, Color.pink, Color.gray]
    public var themeColor: Color {
        return themeColors[themeIndex]
    }
    public var themeLightDarkNames = ["System", "Light", "Dark"]
    public var themeColorScheme: ColorScheme? {
        if themeLightDark == 1 {
            return .light
        } else if themeLightDark == 2 {
            return .dark
        } else {
            return nil 
        }
    }
    
    @AppStorage("is_subscribed")
    public var isSubscribed: Bool = false
    
    @AppStorage("has_notifications")
    public var hasNotifications: Bool = false
    
    @AppStorage("number_of_launch")
    public var numberOfLaunch = 0
    
    @AppStorage("isHealthDataAllowed")
    public var isHealthDataAllowed = 0
    
    @AppStorage("dailyGoal")
    public var dailyGoal = 200
    
    init(themeIndex: Int) {
        self.themeIndex = UserDefaults.standard.object(forKey: "themeIndex") as? Int ?? 0
        self.themeLightDark = UserDefaults.standard.object(forKey: "themeLightDark") as? Int ?? 0
    }
}

