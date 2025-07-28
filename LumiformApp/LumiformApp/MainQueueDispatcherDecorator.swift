//
//  MainQueueDispatcherDecorator.swift
//  LumiformApp
//
//  Created by Aly Yakan on 28/07/2025.
//

import Lumiform

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }

        completion()
    }
}

extension MainQueueDispatchDecorator: FormLoader where T: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FormImageDataLoader where T: FormImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
