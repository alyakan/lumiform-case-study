//
//  CodableFormStoreTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

final class CodableFormStore: FormStore {

    private struct Cache: Codable {
        let formItem: FormItem
        let timestamp: Date
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func deleteCachedForm(completion: @escaping DeletionCompletion) {

    }
    
    func insert(_ form: Lumiform.Form, timestamp: Date, completion: @escaping InsertionCompletion) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(Cache(formItem: form.rootPage, timestamp: timestamp))
            try encoded.write(to: storeURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.success(nil))
        }

        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(Cache.self, from: data)
            completion(.success(Form(rootPage: decoded.formItem)))
        } catch {
            completion(.failure(error))
        }
    }
}

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

    private func removeFilesFromDisk() {
        try? FileManager.default.removeItem(at: storeURL)
    }
}
