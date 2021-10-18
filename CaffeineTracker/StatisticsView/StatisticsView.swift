//
//  StatisticsView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/17/20.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var itemsCDList: FetchedResults<Item>
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)]) var categoryList: FetchedResults<Category>
    
    @State var selectedPie: String = ""
    @State var amountToggle = false
    
    var sample: [ChartCellModel] {
        return computePieChart()
    }
    
//    let sample = [ ChartCellModel(color: Color.red, value: 123, name: "Math"),
//                   ChartCellModel(color: Color.yellow, value: 233, name: "Physics"),
//                   ChartCellModel(color: Color.pink, value: 73, name: "Chemistry"),
//                   ChartCellModel(color: Color.blue, value: 731, name: "Litrature"),
//                   ChartCellModel(color: Color.green, value: 51, name: "Art")]
    
    var weekDateRage: [Date] {
        return [NSCalendar.current.date(byAdding: .day, value: -6, to: Date())!,
                NSCalendar.current.date(byAdding: .day, value: -5, to: Date())!,
                NSCalendar.current.date(byAdding: .day, value: -4, to: Date())!,
                NSCalendar.current.date(byAdding: .day, value: -3, to: Date())!,
                NSCalendar.current.date(byAdding: .day, value: -2, to: Date())!,
                NSCalendar.current.date(byAdding: .day, value: -1, to: Date())!,
                Date()]
    }
    
    var bars: [Double] {
        var returnThis = [Double]()
        for daysBefore in 0..<7{
            returnThis.append(totalAmountToday(inputList: getTodaysItems(inputList: itemsCDList, xAxisDate: NSCalendar.current.date(byAdding: .day, value: -6+daysBefore, to: Date())!)))
        }
        return returnThis
    }
    
    var moreBars: [Double] {
        var returnThis = [Double]()
        for daysBefore in 0..<30{
            returnThis.append(totalAmountToday(inputList: getTodaysItems(inputList: itemsCDList, xAxisDate: NSCalendar.current.date(byAdding: .day, value: -29+daysBefore, to: Date())!)))
        }
        
        return returnThis
    }
    
    var body: some View {
        NavigationView{
            List {
                Section {
                    if bars.isEmpty {
                        Text("There is no data to display chart...")
                    } else {
                        VStack {
                            HStack{
                                Image(systemName: "7.square")
                                Text("Weekly Caffeine Intake")
                                    .font(.system(.headline, design: .rounded))
                            }
                            BarsView(bars: bars)
                                .frame(height: 140)
                                .padding(.bottom)
//                            LegendView(bars: bars)
                            
                            Text("\(NSCalendar.current.date(byAdding: .day, value: -6, to: Date())!, formatter: itemFormatter) - \(Date(), formatter: itemFormatter)")
                                .font(.footnote)
                        }
                    }
                }
                
                Section {
                    if bars.isEmpty {
                        Text("There is no data to display chart...")
                    } else {
                        VStack {
                            HStack{
    //                            Image(systemName: "7.square")
                                Text("Monthly Caffeine Intake")
                                    .font(.system(.headline, design: .rounded))
                            }
                            BarsView(bars: moreBars)
                                .frame(height: 140)
                                .padding(.bottom)
//                            LegendView(bars: bars)
                            
                            Text("\(NSCalendar.current.date(byAdding: .day, value: -30, to: Date())!, formatter: itemFormatter) - \(Date(), formatter: itemFormatter)")
                                .font(.footnote)
                        }
                    }
                }
                
                Section {
                    VStack {
                        Text("Categories Breakdown")
                            .font(.system(.headline, design: .rounded))
                        
                        HStack(spacing: 20) {
                            PieChart(dataModel: ChartDataModel.init(dataModel: sample), onTap: {
                                dataModel in
                                if let dataModel = dataModel {
                                    self.selectedPie = "\(dataModel.name)\nEntries: \(dataModel.value)"
                                } else {
                                    self.selectedPie = ""
                                }
                            })
                                .frame(width: 150, height: 150, alignment: .center)
                                .padding()
                            Text(selectedPie)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            Spacer()
                            
                        }
                        Spacer()
                        HStack {
                            ForEach(sample) { dataSet in
                                VStack {
                                    Circle()
                                        .foregroundColor(dataSet.color)
                                    Text(dataSet.name)
                                        .font(.footnote)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        Toggle(isOn: $amountToggle) {
                            Text("Show Number/Amount")
                        }.padding(.horizontal)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Statistics")
        }
    }
    
    func getTodaysItems(inputList: FetchedResults<Item>, xAxisDate: Date) -> [Item] {
        var outputList = [Item]()
        for item in inputList {
            if Calendar.current.isDate(item.timestamp ?? Date.tomorrow, equalTo: xAxisDate, toGranularity: .day) {
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
    
    func computePieChart() -> [ChartCellModel] {
        var initialList = [ChartCellModel]()
        let colorList = [Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.orange, Color.pink]
        var initialList_justValues = [Int]()
        var initialList_justNames = [String]()
        var found = false
        
        for item in itemsCDList {
            for chartItem in initialList_justNames {
                if chartItem == item.category {
                    found = true
                    break
                }
            }
            if found == false {
                if amountToggle {
                    initialList_justValues.append(Int(item.amount))
                } else {
                    initialList_justValues.append(1)
                }
                initialList_justNames.append(item.category ?? "N/A")
            } else {
                if let loc = initialList_justNames.firstIndex(of: item.category ?? "N/A") {
                    if amountToggle {
                        initialList_justValues[loc] += Int(item.amount)
                    } else {
                        initialList_justValues[loc] += 1
                    }
                } else {
                    print("Something terrible went wrong...")
                }
            }
            found = false
        }
        for index in 0..<initialList_justNames.count {
            let newItem = ChartCellModel(color: colorList[index], value: CGFloat(initialList_justValues[index]), name: initialList_justNames[index])
            initialList.append(newItem)
        }
        
        return initialList
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

