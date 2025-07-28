//
//  QuestionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct QuestionView: View {
    private let viewModel: FormViewModel
    private let question: Question

    init(viewModel: FormViewModel, question: Question) {
        self.viewModel = viewModel
        self.question = question
    }

    var body: some View {
        switch question {
        case .text(let textQuestion):
            Text(textQuestion.title)
                .font(HierarchyFont.questionFont())
        case .image(let imageQuestion):
            ImageQuestionView(viewModel: viewModel.formImageViewModel(for: imageQuestion), question: imageQuestion)
        @unknown default:
            Text("Unknown question format")
                .font(HierarchyFont.questionFont())
        }
    }
}

extension ImageQuestion {
    var pngSourceURL: URL {
        var components = URLComponents(string: sourceURL.absoluteString)!

        if let index = components.queryItems?.firstIndex(where: { $0.name == "size" }) {
            components.queryItems?[index].value = "50x50"
        } else {
            components.queryItems?.append(URLQueryItem(name: "size", value: "50x50"))
        }

        return components.url ?? sourceURL
    }
}
