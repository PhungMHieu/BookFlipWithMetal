//
//  BookPaginator.swift
//  BookFlip
//

import UIKit

struct TextPageSlice {
    let chapterIndex: Int
    let glyphRange: NSRange
    let characterRange: NSRange
}

/// Splits a book into pages with TextKit and renders each page to an image.
///
/// Every chapter has its own layout manager so it always starts on a new page.
/// Pages are rendered with the same layout manager that measured them, so what
/// you see is exactly what was paginated (justified text, paragraph spacing…).
final class BookPaginator {
    let textSize: CGSize
    private(set) var slices: [TextPageSlice] = []

    private var storages: [NSTextStorage] = []
    private var layoutManagers: [NSLayoutManager] = []

    init(book: Book, settings: ReaderSettings, textSize: CGSize) {
        self.textSize = textSize

        for (index, chapter) in book.chapters.enumerated() {
            let storage = NSTextStorage(attributedString: Self.attributedText(for: chapter, number: index + 1, settings: settings))
            let layoutManager = NSLayoutManager()
            storage.addLayoutManager(layoutManager)
            storages.append(storage)
            layoutManagers.append(layoutManager)
            paginate(layoutManager, chapterIndex: index)
        }
    }

    func renderPage(at index: Int) -> UIImage? {
        guard slices.indices.contains(index) else { return nil }
        let slice = slices[index]
        let layoutManager = layoutManagers[slice.chapterIndex]

        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        return UIGraphicsImageRenderer(size: textSize, format: format).image { _ in
            layoutManager.drawBackground(forGlyphRange: slice.glyphRange, at: .zero)
            layoutManager.drawGlyphs(forGlyphRange: slice.glyphRange, at: .zero)
        }
    }

    /// Index of the page in `chapter` that contains `characterLocation`.
    func sliceIndex(chapter: Int, characterLocation: Int) -> Int? {
        let chapterSlices = slices.indices.filter { slices[$0].chapterIndex == chapter }
        return chapterSlices.last { slices[$0].characterRange.location <= characterLocation } ?? chapterSlices.first
    }

    // MARK: - Private

    private func paginate(_ layoutManager: NSLayoutManager, chapterIndex: Int) {
        while true {
            let container = NSTextContainer(size: textSize)
            container.lineFragmentPadding = 0
            layoutManager.addTextContainer(container)

            let glyphRange = layoutManager.glyphRange(for: container)
            guard glyphRange.length > 0 else {
                // Nothing fits (or nothing left): drop the empty container.
                layoutManager.removeTextContainer(at: layoutManager.textContainers.count - 1)
                return
            }

            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            slices.append(TextPageSlice(chapterIndex: chapterIndex, glyphRange: glyphRange, characterRange: characterRange))

            if NSMaxRange(glyphRange) >= layoutManager.numberOfGlyphs { return }
        }
    }

    private static func attributedText(for chapter: Chapter, number: Int, settings: ReaderSettings) -> NSAttributedString {
        let size = settings.fontSize
        let theme = settings.theme
        let text = NSMutableAttributedString()

        // A tall first line pushes the chapter heading down the page.
        let label = NSMutableParagraphStyle()
        label.alignment = .center
        label.minimumLineHeight = size * 4
        label.paragraphSpacing = size * 0.4
        text.append(NSAttributedString(string: "CHƯƠNG \(number)\n", attributes: [
            .font: UIFont.serif(size: size * 0.68, weight: .semibold),
            .kern: size * 0.2,
            .foregroundColor: theme.secondaryInkColor,
            .paragraphStyle: label,
        ]))

        let title = NSMutableParagraphStyle()
        title.alignment = .center
        title.paragraphSpacing = size * 2
        text.append(NSAttributedString(string: chapter.title + "\n", attributes: [
            .font: UIFont.serif(size: size * 1.5, weight: .bold),
            .foregroundColor: theme.inkColor,
            .paragraphStyle: title,
        ]))

        let bodyFont = UIFont.serif(size: size)
        for (index, paragraph) in chapter.paragraphs.enumerated() {
            let isLast = index == chapter.paragraphs.count - 1
            text.append(NSAttributedString(string: paragraph + (isLast ? "" : "\n"), attributes: [
                .font: bodyFont,
                .foregroundColor: theme.inkColor,
                .paragraphStyle: bodyStyle(size: size, indented: index > 0),
            ]))
        }
        return text
    }

    private static func bodyStyle(size: CGFloat, indented: Bool) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
        style.lineSpacing = size * 0.38
        style.paragraphSpacing = size * 0.45
        style.firstLineHeadIndent = indented ? size * 1.4 : 0
        style.hyphenationFactor = 0
        return style
    }
}

extension UIFont {
    /// New York, the system serif face.
    static func serif(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.serif) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}
