//
//  RemoteFormItem.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

// We decode based on the `type` field.
enum RemoteFormItem: Decodable {
    case page(RemotePage)
    case section(RemoteSection)
    case question(RemoteQuestion)

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
            let page = try singleValueContainer.decode(RemotePage.self)
            self = .page(page)
        case .section:
            let section = try singleValueContainer.decode(RemoteSection.self)
            self = .section(section)
        case .text, .image:
            let question = try singleValueContainer.decode(RemoteQuestion.self)
            self = .question(question)
        }
    }
}

struct RemotePage: Decodable {
    let type: String
    let title: String
    let items: [RemoteFormItem]
}

struct RemoteSection: Decodable {
    let type: String
    let title: String
    let items: [RemoteFormItem]
}

enum RemoteQuestion: Decodable {
    case text(RemoteTextQuestion)
    case image(RemoteImageQuestion)

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
            let textQuestion = try singleValueContainer.decode(RemoteTextQuestion.self)
            self = .text(textQuestion)
        case .image:
            let imageQuestion = try singleValueContainer.decode(RemoteImageQuestion.self)
            self = .image(imageQuestion)
        }
    }
}

struct RemoteTextQuestion: Decodable {
    let type: String
    let title: String
}

struct RemoteImageQuestion: Decodable {
    let type: String
    let title: String
    let src: URL
}
