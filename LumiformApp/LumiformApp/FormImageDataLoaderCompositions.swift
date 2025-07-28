//
//  FormImageDataLoaderCompositions.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import Lumiform

final class RemoteImageDataLoaderWithCache: FormImageDataLoader {
    private let remoteLoader: FormImageDataLoader
    private let cache: FormImageDataCacher

    init(remoteLoader: FormImageDataLoader, cache: FormImageDataCacher) {
        self.remoteLoader = remoteLoader
        self.cache = cache
    }

    func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        remoteLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.cache.saveImageData(data, for: url) { cacheResult in
                    print(cacheResult)
                }
                completion(result)
            case .failure:
                completion(result)
            }
        }
    }
}

final class FormImageDataLoaderWithFallback: FormImageDataLoader {
    private let dataLoader: FormImageDataLoader
    private let fallbackLoader: FormImageDataLoader

    init(dataLoader: FormImageDataLoader, fallbackLoader: FormImageDataLoader) {
        self.dataLoader = dataLoader
        self.fallbackLoader = fallbackLoader
    }

    func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        dataLoader.loadImageData(from: url) { [weak self] primaryResult in
            switch primaryResult {
            case .success:
                completion(primaryResult)
            case .failure:
                self?.fallbackLoader.loadImageData(from: url) { fallbackResult in
                    print(fallbackResult)
                    completion(fallbackResult)
                }
            }
        }
    }
}
