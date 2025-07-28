//
//  FormViewModel.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

final class FormViewModel: ObservableObject {
    @Published var rootItem: FormItem?
    @Published var error: String?

    private let loader: FormLoader
    private let imageDataLoader: FormImageDataLoader

    init(loader: FormLoader, imageDataLoader: FormImageDataLoader) {
        self.loader = loader
        self.imageDataLoader = imageDataLoader
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

    func formImageViewModel(for question: ImageQuestion) -> FormImageViewModel {
        return FormImageViewModel(imageDataLoader: imageDataLoader)
    }
}
