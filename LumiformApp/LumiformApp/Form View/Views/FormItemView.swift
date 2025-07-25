//
//  FormItemView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct FormItemView: View {
    let item: FormItem
    let sectionDepth: Int
    let isRootItem: Bool

    init(item: FormItem, sectionDepth: Int, isRootItem: Bool = false) {
        self.item = item
        self.sectionDepth = sectionDepth
        self.isRootItem = isRootItem
    }

    var body: some View {
        switch item {
        case .page(let page):
            PageView(page: page, sectionDepth: sectionDepth, isRoot: isRootItem)
        case .section(let section):
            SectionView(section: section, depth: sectionDepth)
        case .question(let question):
            QuestionView(question: question)
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
