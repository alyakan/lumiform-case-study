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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            switch viewModel.rootItem {
            case .page(let page):
                Text(page.title)
                    .font(.largeTitle)
            case .section(let section):
                Text("Section")
            case .question(let question):
                Text("Question")
            case .none:
                Text("Empty form")
            case .some:
                Text("Unknown form format")
            }
        }
        .padding()
    }
}

#Preview {
    MainView(viewModel: FormViewModel(loader: MockLoader()))
}

class MockLoader: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {

    }
}
