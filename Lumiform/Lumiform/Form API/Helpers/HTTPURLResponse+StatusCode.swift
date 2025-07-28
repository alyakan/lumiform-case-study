//
//  HTTPURLResponse+StatusCode.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }

    public var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
