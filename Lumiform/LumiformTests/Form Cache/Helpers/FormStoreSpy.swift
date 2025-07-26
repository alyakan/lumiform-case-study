//
//  FormStoreSpy.swift
//  Lumiform
//
//  Created by Aly Yakan on 27/07/2025.
//

import Lumiform

final class FormStoreSpy: FormStore {
    private var deletionCompletions: [DeletionCompletion] = []
    private var insertionCompletions: [InsertionCompletion] = []
    private(set) var receivedMessages = [Message]()

    enum Message: Equatable {
        case deleteCachedForm
        case insert(Form, Date)
    }

    func deleteCachedForm(completion: @escaping FormStore.DeletionCompletion) {
        receivedMessages.append(.deleteCachedForm)
        deletionCompletions.append(completion)
    }

    func insert(_ form: Form, timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(form, timestamp))
        insertionCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
