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
            VStack(alignment: .leading, spacing: 16) {
                if !isRootItem {
                    Divider()
                }

                Text(page.title)
                    .font(HierarchyFont.pageFont())

                ForEach(page.items.indices, id: \.self) { idx in
                    FormItemView(item: page.items[idx], sectionDepth: sectionDepth)
                }
            }
        case .section(let section):
            VStack(alignment: .leading, spacing: 12) {
                Text(section.title)
                    .font(HierarchyFont.sectionFont(depth: sectionDepth))

                ForEach(section.items.indices, id: \.self) { idx in
                    let child = section.items[idx]
                    let nextSectionDepth = child.isSection ? sectionDepth + 1 : sectionDepth
                    FormItemView(item: child, sectionDepth: nextSectionDepth)
                }
            }
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
