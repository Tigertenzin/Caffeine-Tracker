//
//  LegendView.swift
//  CaffeineTracker
//
//  Created by Thomas Tenzin on 11/2/20.
//

import SwiftUI

struct LegendView: View {
    @EnvironmentObject var userAppDefaults: AppUserDefaults
    let bars: [Double]

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(self.bars, id: \.self) { bar in
                    Spacer()
                    if bar > 0 {
                        Text("\(String(format: "%.2f", bar))")
                            .font(.caption)
                            .frame(width: 24)
                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        Text("0")
                            .font(.caption)
                            .frame(width: 24)
                    }
                    Spacer()
                }
            }
        }
    }
}
