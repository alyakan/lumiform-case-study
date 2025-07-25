//
//  RemoteFormLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

public final class RemoteFormLoader {
    public typealias Result = Swift.Result<Form, Swift.Error>

    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity, invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    return completion(.failure(Error.invalidData))
                }

                guard let formItem = try? JSONDecoder().decode(FormItem.self, from: data) else {
                    return completion(.failure(Error.invalidData))
                }

                completion(.success(Form(rootPage: formItem)))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
