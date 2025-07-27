//
//  FormCacher.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

public protocol FormCacher {
    typealias SaveResult = Result<Void, Error>

    func save(_ form: Form, completion: @escaping (SaveResult) -> Void)
}
