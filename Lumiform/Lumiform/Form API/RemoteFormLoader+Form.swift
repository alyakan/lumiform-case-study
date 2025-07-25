//
//  RemoteFormLoader+Form.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

extension RemoteFormLoader {

    public struct Form: Equatable {
        public let rootPage: FormItem

        public init(rootPage: FormItem) {
            self.rootPage = rootPage
        }
    }

    // We decode based on the `type` field.
    public enum FormItem: Equatable, Decodable {
        case page(Page)
        case section(Section)
        case question(Question)

        enum CodingKeys: String, CodingKey {
            case type
        }

        public enum ItemType: String, Decodable {
            case page, section, text, image
        }

        public init(from decoder: any Decoder) throws {
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

    public struct Page: Equatable, Decodable {
        public let type: String
        public let title: String
        public let items: [FormItem]

        public init(type: String, title: String, items: [FormItem]) {
            self.type = type
            self.title = title
            self.items = items
        }
    }

    public struct Section: Equatable, Decodable {
        public let type: String
        public let title: String
        public let items: [FormItem]

        public init(type: String, title: String, items: [FormItem]) {
            self.type = type
            self.title = title
            self.items = items
        }
    }

    public enum Question: Equatable, Decodable {
        case text(TextQuestion)
        case image(ImageQuestion)

        enum CodingKeys: String, CodingKey {
            case type
        }

        public enum QuestionType: String, Decodable {
            case text
            case image
        }

        public init(from decoder: any Decoder) throws {
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

    public struct TextQuestion: Equatable, Decodable {
        public let type: String
        public let title: String

        public init(type: String, title: String) {
            self.type = type
            self.title = title
        }
    }

    public struct ImageQuestion: Equatable, Decodable {
        public let type: String
        public let title: String
        public let src: String

        public init(type: String, title: String, src: String) {
            self.type = type
            self.title = title
            self.src = src
        }
    }
}
