//
//  PageMetrics.swift
//  BookFlip
//

import SwiftUI

/// Page size and margins. Text is paginated into `textSize`.
struct PageMetrics: Equatable {
    /// Two pages side by side, like an open book (wide landscape containers, or a vertical fold).
    let isSpread: Bool
    /// Size of one page.
    let pageSize: CGSize
    /// Empty space between the two pages of a spread, covering a vertical fold.
    let gutter: CGFloat
    /// x of the (left) page in the reader's full-screen coordinates.
    let originX: CGFloat
    /// Where the device folds; nothing is drawn there.
    let fold: Fold?
    /// Band of the text area left empty so no line falls under a horizontal fold, in text coordinates.
    let textExclusion: CGRect?
    let contentInsets: EdgeInsets
    /// Height of the band above / below the text holding the running header and page number.
    let headerHeight: CGFloat
    let footerHeight: CGFloat
    /// Leading safe-area inset, to place chrome (laid out inside the safe area) around the fold.
    let safeLeading: CGFloat

    init(containerSize: CGSize, safeArea: EdgeInsets, fold: Fold? = nil) {
        self.fold = fold
        safeLeading = safeArea.leading

        let width: CGFloat
        if let fold, fold.axis == .vertical {
            // One page on each side of the fold, both the same size so they paginate identically.
            isSpread = true
            width = min(fold.range.lowerBound, containerSize.width - fold.range.upperBound).rounded(.down)
            gutter = fold.length
            originX = fold.range.lowerBound - width
        } else {
            isSpread = fold == nil && containerSize.width >= 900 && containerSize.width > containerSize.height
            width = isSpread ? (containerSize.width / 2).rounded(.down) : containerSize.width.rounded()
            gutter = 0
            originX = isSpread ? ((containerSize.width - width * 2) / 2).rounded(.down) : 0
        }
        pageSize = CGSize(width: max(width, 0), height: containerSize.height.rounded())

        let horizontal = max(28, (width * 0.07).rounded(), ((width - 620) / 2).rounded())
        // Both pages of a spread must paginate identically, so they share the larger side inset.
        let side = max(safeArea.leading, safeArea.trailing)
        let top = max(safeArea.top, 20)
        let bottom = max(safeArea.bottom, 12)
        headerHeight = 48
        footerHeight = 44
        contentInsets = EdgeInsets(
            top: top + headerHeight,
            leading: horizontal + (isSpread ? side : safeArea.leading),
            bottom: bottom + footerHeight,
            trailing: horizontal + (isSpread ? side : safeArea.trailing)
        )

        if let fold, fold.axis == .horizontal {
            let text = CGRect(
                x: 0, y: 0,
                width: pageSize.width - contentInsets.leading - contentInsets.trailing,
                height: pageSize.height - contentInsets.top - contentInsets.bottom
            )
            let band = CGRect(x: 0, y: fold.range.lowerBound - contentInsets.top, width: text.width, height: fold.length)
            textExclusion = band.intersects(text) ? band.intersection(text) : nil
        } else {
            textExclusion = nil
        }
    }

    var textSize: CGSize {
        CGSize(
            width: pageSize.width - contentInsets.leading - contentInsets.trailing,
            height: pageSize.height - contentInsets.top - contentInsets.bottom
        )
    }

    /// Width of the whole spread (or the single page).
    var spreadWidth: CGFloat {
        isSpread ? pageSize.width * 2 + gutter : pageSize.width
    }

    /// Room for at least a couple of lines. Containers can be transiently tiny
    /// (first layout pass, a window dragged very short); those are not worth paginating.
    var isUsable: Bool {
        textSize.width >= 100 && textSize.height >= 60
    }

    /// A vertical fold in safe-area coordinates, for chrome laid out inside the safe area.
    var chromeGap: (start: CGFloat, width: CGFloat)? {
        guard let fold, fold.axis == .vertical else { return nil }
        return (fold.range.lowerBound - safeLeading, fold.length)
    }
}
