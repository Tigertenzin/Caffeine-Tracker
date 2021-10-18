//
//  AmountGauge.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 8/22/20.
//

import SwiftUI

struct AmountGauge: View {
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var itemsCDList: FetchedResults<Item>
    
    @Binding var displayDate: Date
    var goal: Int = 200
    
    var body: some View {
        VStack{
            Text("Daily Total Caffeine")
                .font(.system(.headline, design: .rounded))
            GeometryReader { geometry in
                ZStack(alignment: .leading){
                    Rectangle()
                        .frame(width: geometry.size.width, height: 16)
                        .foregroundColor(Color(UIColor.systemFill))
                        .cornerRadius(8)
                    Rectangle()
                        .frame(width: geometry.size.width*gaugeFiller(), height: 16)
                        .foregroundColor(self.userAppDefaults.themeColor)
                        .cornerRadius(8)
                }
            }
            Text("\(String(format: "%.2f", totalAmountToday(inputList: getTodaysItems(inputList: itemsCDList)))) / \(userAppDefaults.dailyGoal)")
                .padding(.horizontal)
        }
    }
    
    func getTodaysItems(inputList: FetchedResults<Item>) -> [Item] {
        var outputList = [Item]()
        for item in inputList {
            if Calendar.current.isDate(item.timestamp ?? Date.tomorrow, equalTo: displayDate, toGranularity: .day) {
                outputList.append(item)
            }
        }
        return outputList
    }
    
    func totalAmountToday(inputList: [Item]) -> Double {
        var total = 0.0
        for item in inputList {
            total += item.amount
        }
        return total
    }
    
    func gaugeFiller() -> CGFloat {
        let testAmount = CGFloat(totalAmountToday(inputList: getTodaysItems(inputList: itemsCDList))/Double(userAppDefaults.dailyGoal))
        if testAmount > 1 {
            return 1
        } else if testAmount < 1/16{
            return 1/16
        } else {
            return testAmount
        }
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
