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
    let isRootItem: Bool

    init(item: FormItem, isRootItem: Bool = false) {
        self.item = item
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
                    .font(.largeTitle)

                ForEach(page.items.indices, id: \.self) { idx in
                    FormItemView(item: page.items[idx])
                }
            }
        case .section(let section):
            VStack(alignment: .leading, spacing: 12) {
                Text(section.title)
                    .font(.title)

                ForEach(section.items.indices, id: \.self) { idx in
                    FormItemView(item: section.items[idx])
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
