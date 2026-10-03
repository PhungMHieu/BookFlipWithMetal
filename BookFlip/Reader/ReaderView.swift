//
//  ReaderView.swift
//  BookFlip
//

import SwiftUI

struct ReaderView: View {
    @State private var viewModel: ReaderViewModel
    @State private var showsSettings = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Brings back the library; dismisses the reader when nil.
    private let onShowLibrary: (() -> Void)?

    init(book: Book, onShowLibrary: (() -> Void)? = nil) {
        _viewModel = State(initialValue: ReaderViewModel(book: book))
        self.onShowLibrary = onShowLibrary
    }

    private var theme: ReaderTheme { viewModel.settings.theme }

    var body: some View {
        GeometryReader { proxy in
            // Read insets here, where the safe area is still respected; the page itself bleeds edge to edge.
            let insets = proxy.safeAreaInsets
            let fullSize = CGSize(
                width: proxy.size.width + insets.leading + insets.trailing,
                height: proxy.size.height + insets.top + insets.bottom
            )
            let metrics = PageMetrics(containerSize: fullSize, safeArea: insets)
            ZStack {
                Color(theme.paperColor)

                if let layout = viewModel.metrics, !viewModel.pages.isEmpty {
                    pager(layout: layout)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onChange(of: metrics, initial: true) { _, newValue in
                viewModel.updateMetrics(newValue)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.isChromeVisible {
                topBar.transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.isChromeVisible {
                bottomBar.transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .persistentSystemOverlays(viewModel.isChromeVisible ? .automatic : .hidden)
        // The cover is dark whatever the theme.
        .preferredColorScheme(viewModel.currentIndex == 0 ? .dark : theme.colorScheme)
        .sheet(isPresented: $showsSettings) {
            ReaderSettingsSheet(settings: $viewModel.settings)
        }
    }

    @ViewBuilder
    private func pager(layout: PageMetrics) -> some View {
        if layout.isSpread {
            BookSpreadContainer(
                pageCount: viewModel.pages.count,
                spreadIndex: spreadIndex,
                pageSize: layout.pageSize,
                onTapCenter: toggleChrome
            ) { index, side in
                pageView(at: index, metrics: layout, spineEdge: side == .left ? .trailing : .leading)
            }
        } else {
            PageCurlContainer(
                pageCount: viewModel.pages.count,
                currentIndex: $viewModel.currentIndex,
                size: layout.pageSize,
                backColor: Color(theme.backColor),
                onTapCenter: toggleChrome
            ) { index in
                pageView(at: index, metrics: layout, spineEdge: .leading)
            }
        }
    }

    @ViewBuilder
    private func pageView(at index: Int, metrics: PageMetrics, spineEdge: HorizontalEdge) -> some View {
        switch viewModel.page(at: index) {
        case .cover?:
            PageView(page: .cover, book: viewModel.book, image: nil, chapterTitle: nil,
                     pageNumber: 0, metrics: metrics, theme: theme, spineEdge: spineEdge)
        case let .text(slice, chapter)?:
            PageView(page: .text(slice: slice, chapter: chapter), book: viewModel.book,
                     image: viewModel.image(forSlice: slice),
                     chapterTitle: viewModel.runningHeader(forSlice: slice, chapter: chapter),
                     pageNumber: slice + 1, metrics: metrics, theme: theme, spineEdge: spineEdge)
        case nil:
            // Before the cover or past the last page of a spread: a blank leaf.
            PaperBackground(theme: theme, spineEdge: spineEdge, spineWidth: 56)
                .frame(width: metrics.pageSize.width, height: metrics.pageSize.height)
        }
    }

    /// Spread `k` shows pages `2k - 1` and `2k`; the reading position is its first page.
    private var spreadIndex: Binding<Int> {
        Binding(
            get: { (viewModel.currentIndex + 1) / 2 },
            // Clamped: pagination can change under a turn that is still settling (e.g. on rotation).
            set: { viewModel.currentIndex = min(max($0 * 2 - 1, 0), max(viewModel.pages.count - 1, 0)) }
        )
    }

    /// Pages currently on screen.
    private var visiblePages: ClosedRange<Int> {
        // Clamping keeps `first <= last` even before the first layout, when `pages` is empty.
        let last = max(viewModel.pages.count - 1, 0)
        let index = min(max(viewModel.currentIndex, 0), last)
        guard viewModel.metrics?.isSpread == true else { return index...index }
        let spread = (index + 1) / 2
        return max(spread * 2 - 1, 0)...min(spread * 2, last)
    }

    // MARK: - Chrome

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                if let onShowLibrary { onShowLibrary() } else { dismiss() }
            } label: {
                Image(systemName: horizontalSizeClass == .regular ? "sidebar.left" : "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Thư viện")

            Spacer(minLength: 0)

            VStack(spacing: 1) {
                Text(viewModel.book.title)
                    .font(.subheadline.weight(.semibold))
                Text(viewModel.currentChapterTitle ?? viewModel.book.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .glassEffect()

            Spacer(minLength: 0)

            Button {
                showsSettings = true
            } label: {
                Image(systemName: "textformat.size")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Cỡ chữ và giao diện")
        }
        .padding(.horizontal, 16)
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text(pageLabel)
                    .monospacedDigit()
                Spacer()
                if viewModel.textPageCount > 0, visiblePages.upperBound > 0 {
                    Text("Còn \(viewModel.textPageCount - visiblePages.upperBound) trang")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.footnote)

            Slider(value: pageSliderValue, in: 0...Double(max(viewModel.pages.count - 1, 1)), step: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .frame(maxWidth: 560)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    private var pageLabel: String {
        let pages = visiblePages.filter { $0 > 0 }
        guard let first = pages.first, let last = pages.last else { return "Bìa sách" }
        let range = first == last ? "\(first)" : "\(first)–\(last)"
        return "Trang \(range) / \(viewModel.textPageCount)"
    }

    private var pageSliderValue: Binding<Double> {
        Binding(
            get: { Double(viewModel.currentIndex) },
            set: { viewModel.currentIndex = Int($0.rounded()) }
        )
    }

    private func toggleChrome() {
        withAnimation(.easeInOut(duration: 0.25)) {
            viewModel.isChromeVisible.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        ReaderView(book: .lighthouse)
    }
}
