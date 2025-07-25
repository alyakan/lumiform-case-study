//
//  FormLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

public protocol FormLoader {
    typealias Result = Swift.Result<Form, Error>

    func load(completion: @escaping (Result) -> Void)
}
