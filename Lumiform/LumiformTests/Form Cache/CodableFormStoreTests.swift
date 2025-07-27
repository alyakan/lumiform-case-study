//
//  CodableFormStoreTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

class CodableFormStoreTests: XCTestCase {
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lumiform.store.test")

    override func setUpWithError() throws {
        removeFilesFromDisk()
    }

    override func tearDownWithError() throws {
        removeFilesFromDisk()
    }

    func test_retrieve_deliversNilOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .success(nil))
    }

    func test_retrieve_deliversExpectedFormOnNonEmptyCache() {
        let sut = makeSUT()
        let formToInsert = Form(rootPage: FormItem.simpleSampleData().item)
        let timestamp = Date()

        insert(formToInsert, timestamp, to: sut)

        expect(sut, toRetrieve: .success(formToInsert))
    }

    func test_retrieve_deliversErrorOnCorruptedData() {
        let sut = makeSUT()

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let firstFormToInsert = Form(rootPage: FormItem.simpleSampleData().item)
        let secondFormToInsert = Form(rootPage: FormItem.recursiveSampleData().item)
        let firstTimestamp = Date()
        let secondTimestamp = Date(timeIntervalSinceNow: 1)
        
        insert(firstFormToInsert, firstTimestamp, to: sut)
        insert(secondFormToInsert, secondTimestamp, to: sut)

        expect(sut, toRetrieve: .success(secondFormToInsert))
    }

    func test_deleteCachedFeed_succeedsOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected no error deleting from empty cache, but got \(String(describing: deletionError))")
    }

    func test_deleteCachedFeed_deletesCachedData() {
        let sut = makeSUT()
        let formToInsert = Form(rootPage: FormItem.simpleSampleData().item)
        
        insert(formToInsert, Date(), to: sut)

        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected no error deleting from empty cache, but got \(String(describing: deletionError))")

        expect(sut, toRetrieve: .success(nil))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FormStore {
        let sut = CodableFormStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: FormStore, toRetrieve expectedResult: FormStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedForm), .success(expectedForm)):
                XCTAssertEqual(receivedForm, expectedForm)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func insert(_ formToInsert: Form, _ timestamp: Date, to sut: FormStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.insert(formToInsert, timestamp: timestamp) { insertionResult in
            switch insertionResult {
            case .success:
                break
            case .failure:
                XCTFail("Expected successful insertion, but got: \(insertionResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func deleteCache(from sut: FormStore) -> Error? {
        var deletionError: Error?

        let exp = expectation(description: "Wait for completion")
        sut.deleteCachedForm { receivedResult in
            switch receivedResult {
            case .success:
                break
            case .failure(let error):
                deletionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return deletionError
    }

    private func removeFilesFromDisk() {
        try? FileManager.default.removeItem(at: storeURL)
    }
}
