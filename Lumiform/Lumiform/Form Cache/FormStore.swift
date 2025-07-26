//
//  FormStore.swift
//  Lumiform
//
//  Created by Aly Yakan on 27/07/2025.
//

public protocol FormStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    func deleteCachedForm(completion: @escaping DeletionCompletion)

    func insert(_ form: Form, timestamp: Date, completion: @escaping InsertionCompletion)
}
