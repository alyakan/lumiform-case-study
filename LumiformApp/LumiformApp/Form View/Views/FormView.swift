//
//  FormView.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

struct FormView: View {
    @ObservedObject private var viewModel: FormViewModel

    init(viewModel: FormViewModel) {
        self.viewModel = viewModel
        viewModel.loadData()
    }

    var body: some View {
        ScrollView {
            VStack {
                if let rootItem = viewModel.rootItem {
                    FormItemView(item: rootItem, sectionDepth: 0, isRootItem: true)
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
    FormView(viewModel: FormViewModel(loader: MockLoader()))
}

class MockLoader: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {}
}
