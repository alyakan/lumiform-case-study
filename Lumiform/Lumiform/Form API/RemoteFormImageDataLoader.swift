//
//  RemoteFormImageDataLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public final class RemoteFormImageDataLoader: FormImageDataLoader {
    private let client: HTTPClient
    private let dataValidator: (Data) -> Bool

    public enum Error: Swift.Error {
        case connectivity, invalidResponse, invalidData
    }

    public init(client: HTTPClient, dataValidator: @escaping (Data) -> Bool) {
        self.client = client
        self.dataValidator = dataValidator
    }

    public func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success((data, response)):
                guard response.isOK else {
                    return completion(.failure(Error.invalidResponse))
                }

                guard dataValidator(data) else {
                    return completion(.failure(Error.invalidData))
                }

                completion(.success(data))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
