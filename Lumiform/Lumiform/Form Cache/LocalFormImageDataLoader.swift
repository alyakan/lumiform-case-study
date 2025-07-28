//
//  LocalFormImageDataLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public final class LocalFormImageDataLoader: FormImageDataCacher, FormImageDataLoader {
    private let store: FormImageDataStore

    public init(store: FormImageDataStore) {
        self.store = store
    }
}

extension LocalFormImageDataLoader {

    public enum SaveError: Swift.Error {
        case failed
    }

    public func saveImageData(_ data: Data, for url: URL, completion: @escaping (FormImageDataCacher.Result) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(SaveError.failed))
            }
        }
    }
}

extension LocalFormImageDataLoader {

    public enum LoadError: Swift.Error {
        case failed, notFound
    }

    public func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        store.retrieveData(for: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success(let data):
                guard let data else {
                    return completion(.failure(LoadError.notFound))
                }

                completion(.success(data))
            case .failure:
                completion(.failure(LoadError.failed))
            }
        }
    }
}
