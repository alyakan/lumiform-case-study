//
//  LumiformApp.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI
import Lumiform

enum Constants {
    static let serverURL = URL(string: "https://mocki.io/v1/2d9cfe27-6550-4b12-b5e4-47a8210108a5")!
    static let localFormStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lumiform.store")
    static let localImageDataStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lumiform.imagestore")
}

@main
struct LumiformApp: App {
    private let formViewModel: FormViewModel

    init() {
        let urlSession = URLSession(configuration: .ephemeral)
        let httpClient = URLSessionHTTPClient(session: urlSession)
        let localStore = CodableFormStore(storeURL: Constants.localFormStoreURL)
        let localImageStore = CodableFormStore(storeURL: Constants.localImageDataStoreURL)

        let formLoader = LumiformApp.composeFormLoader(httpClient: httpClient, localStore: localStore)
        let formImageDataLoader = LumiformApp.composeFormImageDataLoader(httpClient: httpClient, localStore: localImageStore)

        formViewModel = FormViewModel(loader: formLoader, imageDataLoader: formImageDataLoader)
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

// MARK: - Helpers

extension LumiformApp {

    private static func composeFormLoader(httpClient: HTTPClient, localStore: FormStore) -> FormLoader {
        let remoteLoader = RemoteFormLoader(url: Constants.serverURL, client: httpClient)
        let localLoader = LocalFormLoader(store: localStore, currentDate: Date.init)
        let remoteLoaderWithCache = RemoteLoaderWithCache(remoteLoader: remoteLoader, formCacher: localLoader)
        let remoteLoaderWithLocalFallback = FormLoaderWithFallback(formLoader: remoteLoaderWithCache, fallbackLoader: localLoader)

        let mainQueueFormLoader = MainQueueDispatchDecorator(decoratee: remoteLoaderWithLocalFallback)
        return mainQueueFormLoader
    }

    private static func composeFormImageDataLoader(httpClient: HTTPClient, localStore: FormImageDataStore) -> FormImageDataLoader {
        let remoteImageDataLoader = RemoteFormImageDataLoader(client: httpClient, dataValidator: { imageData in
            UIImage(data: imageData) != nil
        })
        let localLoader = LocalFormImageDataLoader(store: localStore)
        let remoteLoaderWithCache = RemoteImageDataLoaderWithCache(remoteLoader: remoteImageDataLoader, cache: localLoader)
        let remoteLoaderWithLocalFallback = FormImageDataLoaderWithFallback(dataLoader: remoteLoaderWithCache, fallbackLoader: localLoader)

        let mainQueueFormImageDataLoader = MainQueueDispatchDecorator(decoratee: remoteLoaderWithLocalFallback)
        return mainQueueFormImageDataLoader
    }
}
