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
    public let title: String
    public let items: [FormItem]

    public init(title: String, items: [FormItem]) {
        self.title = title
        self.items = items
    }
}

public struct Section: Equatable {
    public let title: String
    public let items: [FormItem]

    public init(title: String, items: [FormItem]) {
        self.title = title
        self.items = items
    }
}

public enum Question: Equatable {
    case text(TextQuestion)
    case image(ImageQuestion)
}

public struct TextQuestion: Equatable, Decodable {
    public let title: String

    public init(title: String) {
        self.title = title
    }
}

public struct ImageQuestion: Equatable, Decodable {
    public let title: String
    public let sourceURL: URL

    public init(title: String, sourceURL: URL) {
        self.title = title
        self.sourceURL = sourceURL
    }
}
