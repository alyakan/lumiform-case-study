//
//  FormViewModel.swift
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
            case .failure(let error):
                print(String(describing: error))
                self?.error = "Something went wrong"
            }
        }
    }
}
