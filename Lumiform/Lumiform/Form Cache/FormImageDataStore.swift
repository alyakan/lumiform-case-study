//
//  FormImageDataStore.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public protocol FormImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias RetrievalResult = Swift.Result<Data?, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void)
}
