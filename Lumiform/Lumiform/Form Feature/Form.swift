//
//  Form.swift
//  Lumiform
//
//  Created by Aly Yakan on 25/07/2025.
//

public struct Form: Equatable {
    public let rootPage: FormItem

    public init(rootPage: FormItem) {
        self.rootPage = rootPage
    }
}
