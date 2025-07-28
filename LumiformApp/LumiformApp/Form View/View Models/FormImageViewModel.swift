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

    @Published var error: String?
    @Published var uiimages: [String: UIImage] = [:]

    init(imageDataLoader: FormImageDataLoader) {
        self.imageDataLoader = imageDataLoader
    }

    func load(from sourceURL: URL) {
        guard uiimages[sourceURL.absoluteString] == nil else {
            return
        }

        imageDataLoader.loadImageData(from: sourceURL) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    self.error = "Failed to contruct image. Tap to retry."
                    return
                }

                self.uiimages[sourceURL.absoluteString] = image
            case .failure:
                self.error = "Failed to load image. Tap to retry."
            }
        }
    }

    func clearError() {
        error = nil
    }
}
