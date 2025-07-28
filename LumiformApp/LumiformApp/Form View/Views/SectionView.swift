//
//  SectionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct SectionView: View {
    private let viewModel: FormViewModel
    private let section: Lumiform.Section
    private let depth: Int

    init(viewModel: FormViewModel, section: Lumiform.Section, depth: Int) {
        self.viewModel = viewModel
        self.section = section
        self.depth = depth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(HierarchyFont.sectionFont(depth: depth))

            ForEach(section.items.indices, id: \.self) { idx in
                let child = section.items[idx]
                let nextSectionDepth = child.isSection ? depth + 1 : depth
                FormItemView(viewModel: viewModel, item: child, sectionDepth: nextSectionDepth)
            }
        }
    }
}
