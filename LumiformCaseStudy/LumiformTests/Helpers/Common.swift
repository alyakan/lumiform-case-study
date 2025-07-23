//
//  Common.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://some-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "someError", code: 0)
}

func anyData() -> Data {
    Data("some data".utf8)
}
