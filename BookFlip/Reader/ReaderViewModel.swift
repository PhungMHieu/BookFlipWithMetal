//
//  ReaderViewModel.swift
//  BookFlip
//

import Observation
import UIKit

enum ReaderPage: Hashable {
    case cover
    case text(slice: Int, chapter: Int)
}

@Observable
final class ReaderViewModel {
    let book: Book

    var currentIndex = 0 {
        didSet { prefetchNeighbours() }
    }

    var settings = ReaderSettings() {
        didSet {
            guard settings != oldValue else { return }
            relayout()
        }
    }

    var isChromeVisible = true

    private(set) var pages: [ReaderPage] = []
    private(set) var metrics: PageMetrics?

    @ObservationIgnored private var paginator: BookPaginator?
    @ObservationIgnored private var imageCache: [Int: UIImage] = [:]
    @ObservationIgnored private var prefetchTask: Task<Void, Never>?

    init(book: Book) {
        self.book = book
    }

    var textPageCount: Int { max(pages.count - 1, 0) }

    var currentChapterTitle: String? {
        guard case let .text(_, chapter)? = page(at: currentIndex) else { return nil }
        return book.chapters[chapter].title
    }

    func page(at index: Int) -> ReaderPage? {
        pages.indices.contains(index) ? pages[index] : nil
    }

    /// Running header shown above the text; omitted on a chapter's opening page, which has its own heading.
    func runningHeader(forSlice slice: Int, chapter: Int) -> String? {
        guard let location = paginator?.slices[safe: slice]?.characterRange.location, location > 0 else { return nil }
        return book.chapters[chapter].title
    }

    func updateMetrics(_ newMetrics: PageMetrics) {
        // Keep the last good layout rather than pairing new metrics with stale or empty pages.
        guard newMetrics != metrics, newMetrics.isUsable else { return }
        metrics = newMetrics
        relayout()
    }

    /// Rendered text of a page; cached around the current page.
    func image(forSlice slice: Int) -> UIImage? {
        if let cached = imageCache[slice] { return cached }
        guard let image = paginator?.renderPage(at: slice) else { return nil }
        imageCache[slice] = image
        return image
    }

    // MARK: - Private

    private func relayout() {
        guard let metrics, metrics.textSize.width > 0, metrics.textSize.height > 0 else { return }

        // Remember where the reader is so the same text stays on screen.
        var anchor: (chapter: Int, location: Int)?
        if case let .text(slice, chapter)? = page(at: currentIndex), let old = paginator?.slices[safe: slice] {
            anchor = (chapter, old.characterRange.location)
        }

        let paginator = BookPaginator(book: book, settings: settings, textSize: metrics.textSize)
        self.paginator = paginator
        imageCache.removeAll()
        pages = [.cover] + paginator.slices.enumerated().map { .text(slice: $0.offset, chapter: $0.element.chapterIndex) }

        if let anchor, let slice = paginator.sliceIndex(chapter: anchor.chapter, characterLocation: anchor.location) {
            currentIndex = slice + 1
        } else {
            currentIndex = min(currentIndex, pages.count - 1)
        }
    }

    /// Renders the pages next to the current one so a curl never waits for TextKit.
    private func prefetchNeighbours() {
        prefetchTask?.cancel()
        let index = currentIndex
        prefetchTask = Task { [weak self] in
            await Task.yield()
            guard let self, !Task.isCancelled else { return }

            // A spread turn touches up to three pages ahead and two behind.
            let wanted = [index + 1, index + 2, index + 3, index - 1, index - 2].compactMap { pageIndex -> Int? in
                guard case let .text(slice, _)? = self.page(at: pageIndex) else { return nil }
                return slice
            }
            for slice in wanted {
                _ = self.image(forSlice: slice)
            }

            let keep = (index - 4)...(index + 4)
            imageCache = imageCache.filter { keep.contains($0.key + 1) }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
