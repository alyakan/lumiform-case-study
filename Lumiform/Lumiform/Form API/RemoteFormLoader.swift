//
//  RemoteFormLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

public final class RemoteFormLoader: FormLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity, invalidResponse, invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (FormLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.isOK else {
                    return completion(.failure(Error.invalidResponse))
                }

                guard let formItem = try? JSONDecoder().decode(RemoteFormItem.self, from: data) else {
                    return completion(.failure(Error.invalidData))
                }

                completion(.success(Form(rootPage: formItem.toModel())))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

extension RemoteFormItem {
    func toModel() -> FormItem {
        switch self {
        case let .page(page):
            return .page(Page(title: page.title, items: page.items.toModels()))
        case let .section(section):
            return .section(Section(title: section.title, items: section.items.toModels()))
        case let .question(question):
            switch question {
            case let .text(textQuestion):
                return .question(.text(TextQuestion(title: textQuestion.content)))
            case let .image(imageQuestion):
                return .question(.image(ImageQuestion(title: imageQuestion.title, sourceURL: imageQuestion.src)))
            }
        }
    }
}

extension Array where Element == RemoteFormItem {
    func toModels() -> [FormItem] {
        map { $0.toModel() }
    }
}
