//
//  LocalFormImageDataLoaderUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

final class LocalFormImageDataLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url, completion: { _ in })

        XCTAssertEqual(store.receivedMessages, [.retrieveData(for: url)])
    }

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        let expectedError = LocalFormImageDataLoader.LoadError.failed

        expect(sut, toCompleteWith: .failure(expectedError), when: {
            store.completeRetrieval(with: anyNSError())
        })
    }

    func test_loadImageDataFromURL_deliversNotFoundErrorOnDataNotFound() {
        let (sut, store) = makeSUT()
        let notFoundError = LocalFormImageDataLoader.LoadError.notFound

        expect(sut, toCompleteWith: .failure(notFoundError), when: {
            store.completeRetrievalSuccessfully(with: .none)
        })
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FormImageDataLoader, store: FormImageDataStoreSpy) {
        let store = FormImageDataStoreSpy()
        let sut = LocalFormImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: FormImageDataLoader,
        toCompleteWith expectedResult: FormImageDataStore.RetrievalResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load image data")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            case let (.failure(receivedError as LocalFormImageDataLoader.LoadError), .failure(expectedError as LocalFormImageDataLoader.LoadError)):
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
