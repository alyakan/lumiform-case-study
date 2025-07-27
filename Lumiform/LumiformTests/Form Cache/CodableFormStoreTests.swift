//
//  CodableFormStoreTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

final class CodableFormStore: FormStore {
    func deleteCachedForm(completion: @escaping DeletionCompletion) {

    }
    
    func insert(_ form: Lumiform.Form, timestamp: Date, completion: @escaping InsertionCompletion) {

    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(nil))
    }
}

class CodableFormStoreTests: XCTestCase {

    func test_retrieve_deliversNilOnEmptyCache() {
        let sut: FormStore = CodableFormStore()

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
}
