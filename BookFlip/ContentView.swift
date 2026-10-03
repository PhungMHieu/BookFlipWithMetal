//
//  ContentView.swift
//  BookFlip
//
//  Created by HieuPM ikamer on 2/10/26.
//

import SwiftUI

/// Library in the sidebar, reader in the detail column.
///
/// The reader keeps its full width (`.prominentDetail`) so the sidebar slides over it
/// instead of squeezing the pages; on iPad landscape the detail shows a two-page spread.
/// On iPhone the split view collapses into a stack and the reader shows one page.
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedBookID: Book.ID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var compactColumn: NavigationSplitViewColumn = .sidebar

    private var selectedBook: Book? {
        Book.samples.first { $0.id == selectedBookID }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: $compactColumn) {
            LibraryView(selectedBookID: selectedBookID, onSelect: open)
        } detail: {
            if let book = selectedBook {
                ReaderView(book: book, onShowLibrary: showLibrary)
                    .id(book.id)
            } else {
                ContentUnavailableView(
                    "Chọn một cuốn sách",
                    systemImage: "books.vertical",
                    description: Text("Chọn sách trong thư viện để bắt đầu đọc.")
                )
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
    }

    private func open(_ book: Book) {
        selectedBookID = book.id
        compactColumn = .detail
        withAnimation {
            columnVisibility = .detailOnly
        }
    }

    private func showLibrary() {
        if horizontalSizeClass == .compact {
            compactColumn = .sidebar
        } else {
            withAnimation {
                columnVisibility = .all
            }
        }
    }
}

#Preview {
    ContentView()
}
