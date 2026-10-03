//
//  LibraryView.swift
//  BookFlip
//

import SwiftUI

/// Sidebar of the split view: the book shelf.
struct LibraryView: View {
    var selectedBookID: Book.ID?
    var onSelect: (Book) -> Void

    private let books = Book.samples
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 20, alignment: .top)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Kéo mép trang để lật. Xoay ngang iPad để đọc hai trang.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)

                LazyVGrid(columns: columns, spacing: 28) {
                    ForEach(books) { book in
                        Button {
                            onSelect(book)
                        } label: {
                            BookCell(book: book, isSelected: book.id == selectedBookID)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Thư viện")
    }
}

private struct BookCell: View {
    let book: Book
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BookCoverView(book: book)
                .aspectRatio(2 / 3, contentMode: .fit)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 2, y: 8)

            Text(book.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            if isSelected {
                Label("Đang đọc", systemImage: "book.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tint)
            } else {
                Text("\(book.chapters.count) chương")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        LibraryView(selectedBookID: Book.lighthouse.id) { _ in }
    }
}
