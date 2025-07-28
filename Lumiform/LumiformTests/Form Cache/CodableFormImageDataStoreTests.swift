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
        try removeFilesFromDisk()
    }

    override func tearDownWithError() throws {
        try removeFilesFromDisk()
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

    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let url = anyURL()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)

        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: .success(lastStoredData), for: url)
    }

    func test_operations_runSerially() {
        let sut = makeSUT()
        let url = anyURL()
        let firstStoredData = Data("first".utf8)
        let secondStoredData = Data("second".utf8)
        let lastStoredData = Data("last".utf8)

        let op1 = expectation(description: "Operation 1")
        sut.insert(firstStoredData, for: url) { _ in op1.fulfill() }

        let op2 = expectation(description: "Operation 2")
        sut.insert(secondStoredData, for: url) { _ in op2.fulfill() }

        let op3 = expectation(description: "Operation 3")
        sut.insert(lastStoredData, for: url) { _ in op3.fulfill() }

        wait(for: [op1, op2, op3], timeout: 5.0)

        expect(sut, toCompleteRetrievalWith: .success(lastStoredData), for: url)
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

    private func removeFilesFromDisk() throws {
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: storeURL.path(), isDirectory: &isDir) else {
            return
        }
        try FileManager.default.removeItem(at: storeURL)
    }

    private func form() -> Form {
        Form(rootPage: FormItem.simpleSampleData().item)
    }
}
