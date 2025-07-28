//
//  FormImageViewModel.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import SwiftUI
import Lumiform

final class FormImageViewModel: ObservableObject {
    private let imageDataLoader: FormImageDataLoader

    @Published var uiimage: UIImage?
    @Published var error: String?

    init(imageDataLoader: FormImageDataLoader) {
        self.imageDataLoader = imageDataLoader
    }

    func load(from sourceURL: URL) {
        error = nil
        imageDataLoader.loadImageData(from: sourceURL) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    self.error = "Failed to contruct image. Tap to retry."
                    return
                }

                self.uiimage = image
            case .failure:
                self.error = "Failed to load image. Tap to retry."
            }
        }
    }
}
