//
//  PageView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct PageView: View {
    let page: Page
    let sectionDepth: Int
    let isRoot: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isRoot {
                Divider()
            }

            Text(page.title)
                .font(HierarchyFont.pageFont())

            ForEach(page.items.indices, id: \.self) { idx in
                FormItemView(item: page.items[idx], sectionDepth: sectionDepth)
            }
        }
    }
}
