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

#Preview {
    MainView(viewModel: FormViewModel(loader: MockLoader()))
}

class MockLoader: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {

    }
}
