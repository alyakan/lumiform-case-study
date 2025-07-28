//
//  CacheFormImageDataUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

protocol FormImageDataCacher {
    typealias Result = (Swift.Result<Data, Error>) -> Void

    func saveImageData(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFormImageDataLoader: FormImageDataCacher {
    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func saveImageData(_ data: Data, for url: URL, completion: @escaping (FormImageDataCacher.Result) -> Void) {
        store.insert(data, for: url) { _ in }
    }
}

class CacheFormImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()

        sut.saveImageData(anyData(), for: anyURL()) { _ in }

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FormImageDataCacher, FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFormImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private class FeedImageDataStoreSpy: FeedImageDataStore {
        private var insertionCompletions: [(FeedImageDataStore.InsertionResult) -> Void] = []

        private(set) var receivedMessages = [Message]()

        enum Message: Equatable {
            case insert(data: Data, for: URL)
        }

        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
            insertionCompletions.append(completion)
        }
    }
}
