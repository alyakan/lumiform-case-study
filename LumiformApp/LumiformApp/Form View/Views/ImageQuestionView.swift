//
//  ImageQuestionView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import SwiftUI
import Lumiform

struct ImageQuestionView: View {
    @State private var showFullScreen = false
    @ObservedObject private var viewModel: FormImageViewModel
    private let question: ImageQuestion

    init(viewModel: FormImageViewModel, question: ImageQuestion) {
        self.viewModel = viewModel
        self.question = question

        viewModel.load(from: question.pngSourceURL)
    }

    var body: some View {
        if let uiimage = viewModel.uiimages[question.pngSourceURL.absoluteString] {
            Image(uiImage: uiimage)
                .onTapGesture {
                    showFullScreen = true
                }
                .sheet(isPresented: $showFullScreen) {
                    FullImageQuestionView(viewModel: viewModel, question: question)
                }
        } else if let error = viewModel.error {
            Text(error)
                .font(HierarchyFont.questionFont())
                .onTapGesture { viewModel.load(from: question.pngSourceURL) }
        }

        Text(question.title)
            .font(HierarchyFont.questionFont())
    }
}
