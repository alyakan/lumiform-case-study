//
//  RemoteFormLoader.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

public protocol FormLoader {
    typealias Result = Swift.Result<Form, Error>

    func load(completion: @escaping (Result) -> Void)
}

public final class RemoteFormLoader: FormLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity, invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (FormLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    return completion(.failure(Error.invalidData))
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
            return .page(Page(type: page.type, title: page.title, items: page.items.toModels()))
        case let .section(section):
            return .section(Section(type: section.type, title: section.title, items: section.items.toModels()))
        case let .question(question):
            switch question {
            case let .text(textQuestion):
                return .question(.text(TextQuestion(type: textQuestion.type, title: textQuestion.title)))
            case let .image(imageQuestion):
                return .question(.image(ImageQuestion(type: imageQuestion.type, title: imageQuestion.title, src: imageQuestion.src)))
            }
        }
    }
}

extension Array where Element == RemoteFormItem {
    func toModels() -> [FormItem] {
        map { $0.toModel() }
    }
}
