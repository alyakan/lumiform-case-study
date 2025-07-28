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
    static let localFormStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("lumiform.store")
}

@main
struct LumiformApp: App {
    private let formViewModel: FormViewModel

    init() {
        let urlSession = URLSession(configuration: .ephemeral)
        let httpClient = URLSessionHTTPClient(session: urlSession)
        let localStore = CodableFormStore(storeURL: Constants.localFormStoreURL)

//        let remoteLoader = RemoteFormLoader(url: Constants.serverURL, client: httpClient)
        let remoteLoader = FormLoaderStub() // TODO: Remove when the server works
        let localLoader = LocalFormLoader(store: localStore, currentDate: Date.init)
        let remoteLoaderWithCache = RemoteLoaderWithCache(remoteLoader: remoteLoader, formCacher: localLoader)
        let remoteLoaderWithLocalFallback = FormLoaderWithFallback(formLoader: remoteLoaderWithCache, fallbackLoader: localLoader)

        let mainQueueFormLoader = MainQueueDispatchDecorator(decoratee: remoteLoaderWithLocalFallback)

        self.formViewModel = FormViewModel(loader: mainQueueFormLoader)
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

final class FormLoaderStub: FormLoader {
    func load(completion: @escaping (FormLoader.Result) -> Void) {
        completion(.success(Form(rootPage: FormLoaderStub.recursiveSampleData().item)))
    }

    static func recursiveSampleData() -> (item: FormItem, data: Data) {
        let jsonString = """
        {
              "type": "page",
              "title": "Main Page",
              "items": [
                {
                  "type": "section",
                  "title": "Introduction",
                  "items": [
                    {
                      "type": "text",
                      "title": "Welcome to the main page!"
                    },
                    {
                      "type": "image",
                      "src": "https://robohash.org/280?&set=set4&size=400x400",
                      "title": "Welcome Image"
                    }
                  ]
                },
                {
                  "type": "section",
                  "title": "Chapter 1",
                  "items": [
                    {
                      "type": "text",
                      "title": "This is the first chapter."
                    },
                    {
                      "type": "section",
                      "title": "Subsection 1.1",
                      "items": [
                        {
                          "type": "text",
                          "title": "This is a subsection under Chapter 1."
                        },
                        {
                          "type": "image",
                          "src": "https://robohash.org/100?&set=set4&size=400x400",
                          "title": "Chapter 1 Image"
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "page",
                  "title": "Second Page",
                  "items": [
                    {
                      "type": "section",
                      "title": "Chapter 2",
                      "items": [
                        {
                          "type": "text",
                          "title": "This is the second chapter."
                        },
                        {
                          "type": "text",
                          "title": "What is the main topic of Chapter 2?"
                        }
                      ]
                    }
                  ]
                }
              ]
            } 
        """

        let form = FormItem.page(Page(title: "Main Page", items: [
            FormItem.section(Section(title: "Introduction", items: [
                FormItem.question(Question.text(TextQuestion(title: "Welcome to the main page!"))),
                FormItem.question(Question.image(ImageQuestion(title: "Welcome Image", sourceURL: URL(string: "https://robohash.org/280?&set=set4&size=400x400")!)))
            ])),
            FormItem.section(Section(title: "Chapter 1", items: [
                FormItem.question(Question.text(TextQuestion(title: "This is the first chapter."))),
                FormItem.section(Section(title: "Subsection 1.1", items: [
                    FormItem.question(Question.text(TextQuestion(title: "This is a subsection under Chapter 1."))),
                    FormItem.question(Question.image(ImageQuestion(title: "Chapter 1 Image", sourceURL: URL(string: "https://robohash.org/100?&set=set4&size=400x400")!)))
                ]))
            ])),
            FormItem.page(Page(title: "Second Page", items: [
                FormItem.section(Section(title: "Chapter 2", items: [
                    FormItem.question(Question.text(TextQuestion(title: "This is the second chapter."))),
                    FormItem.question(Question.text(TextQuestion(title: "What is the main topic of Chapter 2?")))
                ]))
            ]))
        ]))

        return (form, Data(jsonString.utf8))
    }
}
