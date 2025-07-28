//
//  FormImageDataCacher.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public protocol FormImageDataCacher {
    typealias Result = Swift.Result<Void, Error>

    func saveImageData(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
