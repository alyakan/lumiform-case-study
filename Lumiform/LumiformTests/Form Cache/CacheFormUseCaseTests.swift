//
//  CacheFormUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 26/07/2025.
//

import XCTest
import Lumiform

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

        expect(sut, toCompleteWithError: expectedError, when: {
            store.completeDeletion(with: anyNSError())
        })
    }

    func test_save_completesWithErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let expectedError = LocalFormLoader.Error.insertionFailed

        expect(sut, toCompleteWithError: expectedError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: anyNSError())
        })
    }

    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()

        expectSuccessfulCompletionFor(sut, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTDeallocation() {
        let store = FormStoreSpy()
        var sut: LocalFormLoader? = LocalFormLoader(store: store, currentDate: Date.init)

        var receivedResults: [LocalFormLoader.SaveResult] = []
        sut?.save(simpleForm()) { result in
            receivedResults.append(result)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected no results, but got: \(receivedResults)")
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTDeallocation() {
        let store = FormStoreSpy()
        var sut: LocalFormLoader? = LocalFormLoader(store: store, currentDate: Date.init)

        var receivedResults: [LocalFormLoader.SaveResult] = []
        sut?.save(simpleForm()) { result in
            receivedResults.append(result)
        }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected no results, but got: \(receivedResults)")
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

    private func expect(
        _ sut: LocalFormLoader,
        toCompleteWithError expectedError: LocalFormLoader.Error,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

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

        action()

        wait(for: [exp], timeout: 1.0)
    }

    func expectSuccessfulCompletionFor(_ sut: LocalFormLoader, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(simpleForm()) { result in
            switch result {
            case .success:
                break
            case .failure(let receivedError):
                XCTFail("Expected to succeed, but got \(receivedError)")
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func simpleForm() -> Form {
        Form(rootPage: FormItem.simpleSampleData().item)
    }
}
