//
//  SectionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct SectionView: View {
    let section: Lumiform.Section
    let depth: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(HierarchyFont.sectionFont(depth: depth))

            ForEach(section.items.indices, id: \.self) { idx in
                let child = section.items[idx]
                let nextSectionDepth = child.isSection ? depth + 1 : depth
                FormItemView(item: child, sectionDepth: nextSectionDepth)
            }
        }
    }
}
