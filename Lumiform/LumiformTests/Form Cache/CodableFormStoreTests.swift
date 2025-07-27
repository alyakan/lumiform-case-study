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

        let exp = expectation(description: "Wait for completion")
        sut.retrieve { receivedResult in
            switch receivedResult {
            case .success(let receivedForm):
                XCTAssertNil(receivedForm, "Expected nil form but got: \(receivedForm!)")
            default:
                XCTFail("Expected success with nil form but got: \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieve_afterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let formToInsert = Form(rootPage: FormItem.simpleSampleData().item)
        let timestamp = Date()

        let exp = expectation(description: "Wait for completion")
        sut.insert(formToInsert, timestamp: timestamp) { insertionResult in
            switch insertionResult {
            case .success:
                sut.retrieve { retrievalResult in
                    switch retrievalResult {
                    case .success(let receivedForm):
                        guard let receivedForm else { return XCTFail("Expected non-nil form but got nil") }
                        XCTAssertEqual(receivedForm, formToInsert, "Expected to retrieve the form we inserted, but got: \(receivedForm)")
                    case .failure:
                        XCTFail("Expected successful retrieval, but got: \(retrievalResult)")
                    }
                    exp.fulfill()
                }
            case .failure:
                XCTFail("Expected successful insertion, but got: \(insertionResult)")
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FormStore {
        let sut = CodableFormStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func removeFilesFromDisk() {
        try? FileManager.default.removeItem(at: storeURL)
    }
}
