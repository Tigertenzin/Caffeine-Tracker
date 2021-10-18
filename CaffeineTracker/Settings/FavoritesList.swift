//
//  FavoritesList.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 10/17/20.
//

import SwiftUI

struct FavoritesList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var categoryList: FetchedResults<Category>
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var FavoriteList: FetchedResults<Favorite>
    
    @State var showAddSheet = false
    
    var body: some View {
        List {
            Section {
                ForEach(FavoriteList, id: \.id) { favorite in
                    NavigationLink(destination: EditFavoritesView(editFavorite: favorite)) {
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
                        }
                        .padding(4)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Favorites")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {self.showAddSheet.toggle()}) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NewFavoriteSheet()
                .accentColor(self.userAppDefaults.themeColor)
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
}

struct FavoritesList_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesList()
    }
}
