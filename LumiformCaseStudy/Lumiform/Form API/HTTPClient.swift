//
//  HTTPClient.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

public protocol HTTPClient {
    typealias Response = (Data, HTTPURLResponse)
    typealias Result = Swift.Result<Response, Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
