//
//  FormImageDataStoreSpy.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import Lumiform

class FormImageDataStoreSpy: FormImageDataStore {
    private var insertionCompletions: [(FormImageDataStore.InsertionResult) -> Void] = []
    private var retrievalCompletions: [(RetrievalResult) -> Void] = []

    private(set) var receivedMessages = [Message]()

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieveData(for: URL)
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        receivedMessages.append(.retrieveData(for: url))
        retrievalCompletions.append(completion)
    }

    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }

    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
}
