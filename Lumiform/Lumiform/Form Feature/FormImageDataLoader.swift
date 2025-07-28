//
//  FormImageDataLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public protocol FormImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}
