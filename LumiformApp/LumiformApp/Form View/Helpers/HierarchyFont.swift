//
//  HierarchyFont.swift
//  LumiformApp
//
//  Created by Aly Yakan on 25/07/2025.
//

import SwiftUI

enum HierarchyFont {
    static func pageFont() -> Font {
        .largeTitle
    }

    static func sectionFont(depth: Int = 0) -> Font {
        switch depth {
        case 0: .title
        case 1: .title2
        case 2: .title3
        default: .headline
        }
    }

    static func questionFont() -> Font {
        .subheadline
    }
}
