//
//  CodableFormImageDataStoreTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

class CodableFormImageDataStoreTests: XCTestCase {
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lumiform.imageStore.test")

    override func setUpWithError() throws {
        removeFilesFromDisk()
    }

    override func tearDownWithError() throws {
        removeFilesFromDisk()
    }

    func test_retrieveImageData_deliversNilOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: .success(nil))
    }

    func test_retrieveImageData_deliversNotFoundWhenURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: .success(.none), for: nonMatchingURL)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FormImageDataStore {
        let sut = CodableFormStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(
        _ sut: FormImageDataStore,
        toCompleteRetrievalWith expectedResult: FormImageDataStore.RetrievalResult,
        for url: URL = URL(string: "some-url")!,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        sut.retrieveData(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func insert(_ data: Data, for url: URL, into store: FormImageDataStore, file: StaticString = #file, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Wait for completion")

        store.insert(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    private func removeFilesFromDisk() {
        try? FileManager.default.removeItem(at: storeURL)
    }

    private func form() -> Form {
        Form(rootPage: FormItem.simpleSampleData().item)
    }
}
