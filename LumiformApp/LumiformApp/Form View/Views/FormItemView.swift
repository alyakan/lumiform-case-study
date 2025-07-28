//
//  FormItemView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct FormItemView: View {
    private let viewModel: FormViewModel
    private let item: FormItem
    private let sectionDepth: Int
    private let isRootItem: Bool

    init(viewModel: FormViewModel, item: FormItem, sectionDepth: Int, isRootItem: Bool = false) {
        self.viewModel = viewModel
        self.item = item
        self.sectionDepth = sectionDepth
        self.isRootItem = isRootItem
    }

    var body: some View {
        switch item {
        case .page(let page):
            PageView(viewModel: viewModel, page: page, sectionDepth: sectionDepth, isRoot: isRootItem)
        case .section(let section):
            SectionView(viewModel: viewModel, section: section, depth: sectionDepth)
        case .question(let question):
            QuestionView(viewModel: viewModel, question: question)
        @unknown default:
            Text("Unknown form item")
                .font(.title)
        }
    }
}

extension FormItem {

    var isSection: Bool {
        switch self {
        case .section:
            true
        default:
            false
        }
    }
}
