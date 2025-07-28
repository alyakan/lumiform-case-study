//
//  FormLoaderCompositions.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import Lumiform

/// Caches the form on successful retrieval from remote source.
final class RemoteLoaderWithCache: FormLoader {
    private let remoteLoader: FormLoader
    private let formCacher: FormCacher

    init(remoteLoader: FormLoader, formCacher: FormCacher) {
        self.remoteLoader = remoteLoader
        self.formCacher = formCacher
    }

    func load(completion: @escaping (FormLoader.Result) -> Void) {
        remoteLoader.load { [weak self] loadResult in
            guard let self else { return }

            switch loadResult {
            case .success(let form):
                formCacher.save(form, completion: { _ in })
                completion(.success(form))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

/// Executes the `fallbackLoader.load` once on `formLoader.load` failure.
final class FormLoaderWithFallback: FormLoader {
    private let formLoader: FormLoader
    private let fallbackLoader: FormLoader

    init(formLoader: FormLoader, fallbackLoader: FormLoader) {
        self.formLoader = formLoader
        self.fallbackLoader = fallbackLoader
    }

    func load(completion: @escaping (FormLoader.Result) -> Void) {
        formLoader.load { [weak self] loadResult in
            guard let self else { return }

            switch loadResult {
            case .success(let form):
                completion(.success(form))
            case .failure:
                fallbackLoader.load(completion: completion)
            }
        }
    }
}
