//
//  FormItem.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

// By having separate models from our `remote` ones, we hide the `Decodable` implementation details from our business logic.

public enum FormItem: Equatable {
    case page(Page)
    case section(Section)
    case question(Question)
}

public struct Page: Equatable {
    public let type: String
    public let title: String
    public let items: [FormItem]

    public init(type: String, title: String, items: [FormItem]) {
        self.type = type
        self.title = title
        self.items = items
    }
}

public struct Section: Equatable {
    public let type: String
    public let title: String
    public let items: [FormItem]

    public init(type: String, title: String, items: [FormItem]) {
        self.type = type
        self.title = title
        self.items = items
    }
}

public enum Question: Equatable {
    case text(TextQuestion)
    case image(ImageQuestion)
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
