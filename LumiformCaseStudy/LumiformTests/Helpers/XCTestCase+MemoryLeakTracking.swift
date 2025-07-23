//
//  XCTestCase+MemoryLeakTracking.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

import XCTest

extension XCTestCase {

    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        let message = "Instance should have been deallocated. Potential memory leak detected."
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, message, file: file, line: line)
        }
    }
}
