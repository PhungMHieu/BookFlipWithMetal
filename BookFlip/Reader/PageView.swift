//
//  PageView.swift
//  BookFlip
//

import SwiftUI

/// One full-screen page. Rendered as plain SwiftUI so the curl shader can rasterize it.
struct PageView: View {
    let page: ReaderPage
    let book: Book
    let image: UIImage?
    let chapterTitle: String?
    let pageNumber: Int
    let metrics: PageMetrics
    let theme: ReaderTheme
    /// Side bound into the book: left edge for a right-hand page, right edge for a left-hand page.
    var spineEdge: HorizontalEdge = .leading

    var body: some View {
        ZStack(alignment: .topLeading) {
            PaperBackground(theme: theme, spineEdge: spineEdge, spineWidth: metrics.isSpread ? 56 : 26)

            switch page {
            case .cover:
                BookCoverView(book: book, style: .page)
            case .text:
                textPage
            }
        }
        .frame(width: metrics.pageSize.width, height: metrics.pageSize.height)
    }

    private var textPage: some View {
        VStack(spacing: 0) {
            Text(chapterTitle?.uppercased() ?? "")
                .font(.system(size: 11, weight: .medium, design: .serif))
                .kerning(1.6)
                .lineLimit(1)
                .foregroundStyle(Color(theme.secondaryInkColor))
                .frame(maxWidth: .infinity)
                .frame(height: metrics.headerHeight)

            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    Color.clear
                }
            }
            .frame(width: metrics.textSize.width, height: metrics.textSize.height)

            Text("\(pageNumber)")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .monospacedDigit()
                .foregroundStyle(Color(theme.secondaryInkColor))
                .frame(maxWidth: .infinity)
                .frame(height: metrics.footerHeight)
        }
        .padding(.top, metrics.contentInsets.top - metrics.headerHeight)
        .padding(.leading, metrics.contentInsets.leading)
        .padding(.trailing, metrics.contentInsets.trailing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(chapterTitle ?? "")
        .accessibilityValue("Trang \(pageNumber)")
    }
}

/// Paper color with a procedural grain shader, shaded toward the spine.
struct PaperBackground: View {
    let theme: ReaderTheme
    var spineEdge: HorizontalEdge = .leading
    var spineWidth: CGFloat = 26

    var body: some View {
        let spine: UnitPoint = spineEdge == .leading ? .leading : .trailing
        let outer: UnitPoint = spineEdge == .leading ? .trailing : .leading

        Rectangle()
            .fill(Color(theme.paperColor))
            .colorEffect(ShaderLibrary.paperGrain(.float(theme.grainStrength)))
            .overlay(alignment: spineEdge == .leading ? .leading : .trailing) {
                LinearGradient(
                    colors: [.black.opacity(theme.spineShadowOpacity), .clear],
                    startPoint: spine,
                    endPoint: outer
                )
                .frame(width: spineWidth)
            }
            .overlay(alignment: spineEdge == .leading ? .trailing : .leading) {
                LinearGradient(
                    colors: [.black.opacity(theme.spineShadowOpacity * 0.4), .clear],
                    startPoint: outer,
                    endPoint: spine
                )
                .frame(width: 8)
            }
    }
}
