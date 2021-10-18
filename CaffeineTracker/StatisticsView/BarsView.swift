//
//  BarView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 11/2/20.
//

import SwiftUI

struct BarsView: View {
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    let bars: [Double]

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(self.bars, id: \.self) { bar in
                    VStack{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bar > 0 ? self.userAppDefaults.themeColor : .gray)
                            .frame(height: CGFloat(bar+8) / CGFloat(bars.max() ?? 1000) * geometry.size.height)
                            .accessibility(value: Text("\(bar) milligrams"))
                    }
                }
            }
        }
    }
}
