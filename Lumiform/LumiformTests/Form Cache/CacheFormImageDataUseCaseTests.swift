//
//  CacheFormImageDataUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

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

    func test_saveImageDataForURL_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .failure(LocalFormImageDataLoader.SaveError.failed), when: {
            store.completeInsertion(with: anyNSError())
        })
    }

    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }

    func test_saveImageDataForURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FormImageDataStoreSpy()
        var sut: LocalFormImageDataLoader? = LocalFormImageDataLoader(store: store)

        var receivedResults: [FormImageDataStore.InsertionResult] = []
        sut?.saveImageData(anyData(), for: anyURL()) { result in
            receivedResults.append(result)
        }

        sut = nil
        store.completeInsertion(with: anyNSError())
        store.completeInsertionSuccessfully()

        XCTAssertTrue(receivedResults.isEmpty, "Expected no result, but received: \(String(describing: receivedResults))")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FormImageDataCacher, FormImageDataStoreSpy) {
        let store = FormImageDataStoreSpy()
        let sut = LocalFormImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: FormImageDataCacher,
        toCompleteWith expectedResult: FormImageDataStore.InsertionResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load image data")
        sut.saveImageData(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError as LocalFormImageDataLoader.SaveError), .failure(expectedError as LocalFormImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }

        action()

        wait(for: [expectation], timeout: 0.1)
    }
}
