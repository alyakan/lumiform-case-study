//
//  PageView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct PageView: View {
    private let viewModel: FormViewModel
    private let page: Page
    private let sectionDepth: Int
    private let isRoot: Bool

    init(viewModel: FormViewModel, page: Page, sectionDepth: Int, isRoot: Bool) {
        self.viewModel = viewModel
        self.page = page
        self.sectionDepth = sectionDepth
        self.isRoot = isRoot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isRoot {
                Divider()
            }

            Text(page.title)
                .font(HierarchyFont.pageFont())

            ForEach(page.items.indices, id: \.self) { idx in
                FormItemView(viewModel: viewModel, item: page.items[idx], sectionDepth: sectionDepth)
            }
        }
    }
}
