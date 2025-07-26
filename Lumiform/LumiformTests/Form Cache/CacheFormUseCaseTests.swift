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

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    func deleteCachedForm(completion: @escaping DeletionCompletion)

    func insert(_ form: Form, timestamp: Date, completion: @escaping InsertionCompletion)
}

final class LocalFormLoader {
    typealias SaveResult = Result<Void, Error>

    private let store: FormStore
    private let currentDate: () -> Date

    enum Error: Swift.Error {
        case existingCacheDeleteFailed
        case instanceDeinitialized
    }

    init(store: FormStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ form: Form, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedForm { [weak self] result in
            switch result {
            case .success:
                guard let self else { return completion(.failure(.instanceDeinitialized)) }

                store.insert(form, timestamp: currentDate()) { _ in
                    completion(.success(()))
                }
            case .failure:
                completion(.failure(.existingCacheDeleteFailed))
            }
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

        sut.save(simpleForm()) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedForm])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        sut.save(simpleForm()) { _ in }
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.deleteCachedForm])
    }

    func test_save_requestsCacheInsertionOnDeletionSuccess() {
        let timestamp = Date()
        let formToInsert = simpleForm()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(formToInsert) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedForm, .insert(formToInsert, timestamp)])
    }

    func test_save_completesWithErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let expectedError = LocalFormLoader.Error.existingCacheDeleteFailed

        let exp = expectation(description: "Wait for completion")
        sut.save(simpleForm()) { result in
            switch result {
            case .success:
                XCTFail("Expected to fail with \(expectedError), but got \(result)")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, expectedError)
            }
            exp.fulfill()
        }
        store.completeDeletion(with: anyNSError())
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (LocalFormLoader, FormStoreSpy) {

        let store = FormStoreSpy()
        let sut = LocalFormLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

    private func simpleForm() -> Form {
        Form(rootPage: FormItem.simpleSampleData().item)
    }
}

final class FormStoreSpy: FormStore {
    private var deletionCompletions: [DeletionCompletion] = []
    private var insertionCompletions: [InsertionCompletion] = []
    private(set) var receivedMessages = [Message]()

    enum Message: Equatable {
        case deleteCachedForm
        case insert(Form, Date)
    }

    func deleteCachedForm(completion: @escaping FormStore.DeletionCompletion) {
        receivedMessages.append(.deleteCachedForm)
        deletionCompletions.append(completion)
    }

    func insert(_ form: Form, timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(form, timestamp))
        insertionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
}
