//
//  LocalFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 26/07/2025.
//

import XCTest
import Lumiform

class LocalFormLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: .retrievalFailed, when: {
            store.completeRetrieval(with: anyNSError())
        })
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FormLoader, FormStoreSpy) {
        let store = FormStoreSpy()
        let sut = LocalFormLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

    private func expect(
        _ sut: FormLoader,
        toCompleteWithError expectedError: LocalFormLoader.Error,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let exp = expectation(description: "Waiting for completion")
        sut.load { receivedResult in
            switch receivedResult {
            case .failure(let receivedError as LocalFormLoader.Error):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected \(expectedError) but got \(receivedResult)")
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
