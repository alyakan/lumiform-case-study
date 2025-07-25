//
//  QuestionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct QuestionView: View {
    let question: Question

    var body: some View {
        switch question {
        case .text(let textQuestion):
            Text(textQuestion.title)
                .font(HierarchyFont.questionFont())
        case .image(let imageQuestion):
            // TODO: Display image
            Text(imageQuestion.title)
                .font(HierarchyFont.questionFont())
        @unknown default:
            Text("Unknown question format")
                .font(HierarchyFont.questionFont())
        }
    }
}
