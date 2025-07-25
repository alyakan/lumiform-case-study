//
//  ContentView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

class FormViewModel: ObservableObject {
    @Published var rootItem: FormItem?
    @Published var error: String?

    private let loader: FormLoader

    init(loader: FormLoader) {
        self.loader = loader
    }

    func loadData() {
        loader.load { [weak self] result in
            switch result {
            case .success(let form):
                self?.rootItem = form.rootPage
            case .failure:
                self?.error = "Something went wrong"
            }
        }
    }
}

struct MainView: View {
    @ObservedObject private var viewModel: FormViewModel

    init(viewModel: FormViewModel) {
        self.viewModel = viewModel
        viewModel.loadData()
    }

    var body: some View {
        ScrollView {
            VStack {
                if let rootItem = viewModel.rootItem {
                    FormItemView(item: rootItem, isRootItem: true)
                } else {
                    Text("Empty Form")
                        .font(.largeTitle)
                }
            }
            .padding()
        }
    }
}

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

struct QuestionView: View {
    let question: Question

    var body: some View {
        switch question {
        case .text(let textQuestion):
            Text(textQuestion.title)
                .font(.subheadline)
        case .image(let imageQuestion):
            // TODO: Display image
            Text(imageQuestion.title)
                .font(.subheadline)
        @unknown default:
            Text("Unknown question format")
                .font(.subheadline)
        }
    }
}

#Preview {
    MainView(viewModel: FormViewModel(loader: MockLoader()))
}

class MockLoader: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {

    }
}
