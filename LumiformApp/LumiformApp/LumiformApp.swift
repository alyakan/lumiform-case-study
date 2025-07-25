//
//  LumiformApp.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

enum Constants {
    static let serverURL = URL(string: "https://mocki.io/v1/f118b9f0-6f84-435e-85d5-faf4453eb72a")!
}

@main
struct LumiformApp: App {
    private let formViewModel: FormViewModel

    init() {
        let urlSession = URLSession(configuration: .default) // TODO: Switch to ephemeral after implementing the caching loader
        let httpClient = URLSessionHTTPClient(session: urlSession)
        let formLoader = MainQueueDispatchDecorator(decoratee: RemoteFormLoader(url: Constants.serverURL, client: httpClient))
        self.formViewModel = FormViewModel(loader: formLoader)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FormView(viewModel: formViewModel)
                    .navigationTitle(Text("Lumiform"))
            }
        }
    }
}

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
