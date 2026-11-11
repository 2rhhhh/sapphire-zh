//
//  CircleToSearchResultsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2026-08-30

#if !SAPPHIRE_FULL_BUILD
import SwiftUI

struct CircleToSearchResultsView: View {
    @Binding var navigationStack: [NotchWidgetMode]

    init(navigationStack: Binding<[NotchWidgetMode]>) {
        _navigationStack = navigationStack
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass.circle.fill").font(.system(size: 22))
            Text("此构建中无法使用“圈选搜索”").font(.caption)
        }
        .frame(width: 320)
    }
}
#endif