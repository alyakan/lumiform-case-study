//
//  CacheFormUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 26/07/2025.
//

import XCTest
import Lumiform

protocol FormStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    func deleteCachedForm(completion: @escaping DeletionCompletion)
}

final class LocalFormCache {
    private let store: FormStore

    init(store: FormStore) {
        self.store = store
    }

    func save(_ form: Form, completion: @escaping () -> Void) {
        store.deleteCachedForm { _ in
            completion()
        }
    }
}

class CacheFormUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(simpleForm()) { }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedForm])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        let exp = expectation(description: "Wait for completion")
        sut.save(simpleForm()) {
            exp.fulfill()
        }
        store.completeDeletion(with: anyNSError())
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFormCache, FormStoreSpy) {
        let store = FormStoreSpy()
        let sut = LocalFormCache(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

    private func simpleForm() -> Form {
        Form(rootPage: FormItem.simpleSampleData().item)
    }

    private class FormStoreSpy: FormStore {
        private var deletionCompletions: [DeletionCompletion] = []
        private(set) var receivedMessages = [Message]()

        enum Message {
            case deleteCachedForm
        }

        func deleteCachedForm(completion: @escaping FormStore.DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedForm)
        }

        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](.failure(error))
        }
    }
}
