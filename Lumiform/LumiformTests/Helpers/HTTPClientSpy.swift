//
//  HTTPClientSpy.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

import Lumiform

final class HTTPClientSpy: HTTPClient {
    private var receivedMessages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []

    var requestedURLs: [URL] {
        receivedMessages.map(\.url)
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        receivedMessages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
        receivedMessages[index].completion(.failure(error))
    }

    func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: receivedMessages[index].url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        receivedMessages[index].completion(.success((data, response)))
    }
}
