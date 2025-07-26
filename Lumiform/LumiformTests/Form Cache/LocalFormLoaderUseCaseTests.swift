//
//  LocalFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 26/07/2025.
//

import XCTest

final class LocalFormLoader {
    init(store: Any) {}
}

class LocalFormLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalFormLoader, FormStoreSpy) {
        let store = FormStoreSpy()
        let sut = LocalFormLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

    private class FormStoreSpy {
        private(set) var receivedMessages = [Any]()
    }
}
