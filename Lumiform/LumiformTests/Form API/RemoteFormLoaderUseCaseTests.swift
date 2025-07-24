//
//  RemoteFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 24/07/2025.
//

import XCTest
import Lumiform

struct Form: Equatable {
    let rootPage: FormItem
}

// We decode based on the `type` field.
enum FormItem: Equatable, Decodable {
    case page(Page)
    case section(Section)
    case question(Question)

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ItemType: String, Decodable {
        case page, section, text, image
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        let singleValueContainer = try decoder.singleValueContainer()

        switch type {
            case .page:
            let page = try singleValueContainer.decode(Page.self)
            self = .page(page)
        case .section:
            let section = try singleValueContainer.decode(Section.self)
            self = .section(section)
        case .text, .image:
            let question = try singleValueContainer.decode(Question.self)
            self = .question(question)
        }
    }
}

struct Page: Equatable, Decodable {
    let type: String
    let title: String
    let items: [FormItem]
}

struct Section: Equatable, Decodable {
    let type: String
    let title: String
    let items: [FormItem]
}

enum Question: Equatable, Decodable {
    case text(TextQuestion)
    case image(ImageQuestion)

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum QuestionType: String, Decodable {
        case text
        case image
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(QuestionType.self, forKey: .type)
        let singleValueContainer = try decoder.singleValueContainer()

        switch type {
        case .text:
            let textQuestion = try singleValueContainer.decode(TextQuestion.self)
            self = .text(textQuestion)
        case .image:
            let imageQuestion = try singleValueContainer.decode(ImageQuestion.self)
            self = .image(imageQuestion)
        }
    }
}

struct TextQuestion: Equatable, Decodable {
    let type: String
    let title: String
}

struct ImageQuestion: Equatable, Decodable {
    let type: String
    let title: String
    let src: String
}

final class RemoteFormLoader {
    typealias Result = Swift.Result<Form, Swift.Error>

    private let url: URL
    private let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity, invalidData
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    return completion(.failure(Error.invalidData))
                }

                guard let formItem = try? JSONDecoder().decode(FormItem.self, from: data) else {
                    return completion(.failure(Error.invalidData))
                }

                completion(.success(Form(rootPage: formItem)))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class RemoteFormLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.requestedURLs, [], "Expected no requests, got: \(client.requestedURLs)")
    }

    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.load() { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }

    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500].enumerated()

        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([:])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidData = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }

    func test_load_deliversFormOn200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        let dataToReturn = FormItem.sampleData()
        let expectedForm = Form(rootPage: dataToReturn.item)

        expect(sut, toCompleteWith: .success(expectedForm), when: {
            client.complete(withStatusCode: 200, data: dataToReturn.data)
        })
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://some-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (RemoteFormLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteFormLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteFormLoader.Error) -> RemoteFormLoader.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteFormLoader,
        toCompleteWith expectedResult: RemoteFormLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let exp = expectation(description: "Waiting for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedForm), .success(expectedForm)):
                XCTAssertEqual(receivedForm, expectedForm, file: file, line: line)
            case let (.failure(receivedError as RemoteFormLoader.Error), .failure(expectedError as RemoteFormLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 0.1)
    }

    private func makeItemsJSON(_ items: [String: Any]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

    final class HTTPClientSpy: HTTPClient {
        private var receivedMessages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []

        var requestedURLs: [URL] {
            receivedMessages.map(\.url)
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedMessages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }

        func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: receivedMessages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            receivedMessages[index].completion(.success((data, response)))
        }
    }
}

extension FormItem {
    static func sampleData() -> (item: FormItem, data: Data) {
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
            }]
        }    
        """

        let form: FormItem = .page(Page(type: "page", title: "Main Page", items: [
            .section(Section(type: "section", title: "Introduction", items: [
                .question(.text(TextQuestion(type: "text", title: "Welcome to the main page!"))),
                .question(.image(ImageQuestion(type: "image", title: "Welcome Image", src: "https://robohash.org/280?&set=set4&size=400x400")))
            ]))
        ]))

        return (form, Data(jsonString.utf8))
    }
}
