//
//  URLSessionHTTPClient.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

public final class URLSessionHTTPClient: HTTPClient {
    private struct UnexpectedValuesError: Error {}

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesError()
                }
            })
        }
        dataTask.resume()
    }
}
