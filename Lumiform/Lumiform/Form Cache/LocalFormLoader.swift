//
//  LocalFormLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 27/07/2025.
//

public final class LocalFormLoader {
    public typealias SaveResult = Result<Void, Error>

    private let store: FormStore
    private let currentDate: () -> Date

    public enum Error: Swift.Error {
        case existingCacheDeleteFailed
        case insertionFailed
        case retrievalFailed
        case emptyCache
    }

    public init(store: FormStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Caching

extension LocalFormLoader {

    public func save(_ form: Form, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedForm { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                cache(form, completion: completion)
            case .failure:
                completion(.failure(.existingCacheDeleteFailed))
            }
        }
    }

    private func cache(_ form: Form, completion: @escaping (SaveResult) -> Void) {
        store.insert(form, timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(Error.insertionFailed))
            }
        }
    }
}

// MARK: - Loading Cache

extension LocalFormLoader: FormLoader {
    public func load(completion: @escaping (FormLoader.Result) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let form):
                guard let form else {
                    return completion(.failure(Error.emptyCache))
                }

                completion(.success(form))
            case .failure:
                store.deleteCachedForm { _ in }
                completion(.failure(Error.retrievalFailed))
            }
        }
    }
}
