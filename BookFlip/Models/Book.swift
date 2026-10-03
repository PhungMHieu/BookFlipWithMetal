//
//  Book.swift
//  BookFlip
//

import SwiftUI

nonisolated struct Book: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let synopsis: String
    let cover: BookCover
    let chapters: [Chapter]
}

nonisolated struct Chapter: Hashable {
    let title: String
    let paragraphs: [String]

    /// Paragraphs in `text` are separated by blank lines.
    init(title: String, text: String) {
        self.title = title
        self.paragraphs = text
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

nonisolated struct BookCover: Hashable {
    let top: Color
    let bottom: Color
    let accent: Color
    let symbol: String
}
