//
//  FullImageQuestionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import SwiftUI
import Lumiform

struct FullImageQuestionView: View {
    @ObservedObject private var viewModel: FormImageViewModel
    private let question: ImageQuestion

    init(viewModel: FormImageViewModel, question: ImageQuestion) {
        self.viewModel = viewModel
        self.question = question

        viewModel.load(from: question.sourceURL)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Text(question.title)
                .font(.title3)

            if viewModel.error == nil && viewModel.uiimages[question.sourceURL.absoluteString] == nil {
                ProgressView()
            }

            if let error = viewModel.error {
                VStack(spacing: 8) {
                    Text(error)
                        .font(.headline)
                    Text("Tap to retry.")
                        .font(.subheadline)
                }
                .onTapGesture {
                    viewModel.clearError()
                    viewModel.load(from: question.sourceURL)
                }
            } else if let uiimage = viewModel.uiimages[question.sourceURL.absoluteString] {
                Image(uiImage: uiimage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

