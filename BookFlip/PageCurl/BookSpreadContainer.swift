//
//  BookSpreadContainer.swift
//  BookFlip
//

import SwiftUI

enum SpreadSide {
    case left
    case right
}

/// Shows two pages side by side like an open book and turns them around the spine.
///
/// Spread `k` shows page `2k - 1` on the left and `2k` on the right, so the cover
/// (page 0) opens alone on the right. Indices outside `0..<pageCount` are still
/// requested from `page` and should render as blank paper.
///
/// - Drag the right page to the left (or tap its outer edge) to turn forward.
/// - Drag the left page to the right (or tap its outer edge) to turn back.
struct BookSpreadContainer<Page: View>: View {
    let pageCount: Int
    @Binding var spreadIndex: Int
    /// Size of one page; the spread is twice as wide.
    let pageSize: CGSize
    var onTapCenter: () -> Void = {}
    @ViewBuilder let page: (Int, SpreadSide) -> Page

    @State private var turn: Turn?
    @State private var isSettling = false

    private var size: CGSize { CGSize(width: pageSize.width * 2, height: pageSize.height) }
    private var spineX: CGFloat { pageSize.width }
    /// Staying under width / π² keeps the spine attached through the whole turn.
    private var maxRadius: CGFloat { size.width * 0.09 }

    private var lastSpread: Int { pageCount / 2 }
    private var spread: Int { min(max(spreadIndex, 0), lastSpread) }
    private var leftIndex: Int { spread * 2 - 1 }
    private var rightIndex: Int { spread * 2 }
    private var canTurnForward: Bool { rightIndex + 1 < pageCount }
    private var canTurnBackward: Bool { spread > 0 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            let base = basePages
            pagePair(left: base.left, right: base.right)

            if let turn {
                let sheet = sheetPages(for: turn.direction)
                pagePair(left: sheet.left, right: sheet.right)
                    .modifier(SpreadCurlEffect(
                        corner: turn.corner,
                        target: turn.target,
                        finish: finish(for: turn.corner),
                        sheet: sheetRect(for: turn.direction),
                        spineX: spineX,
                        maxRadius: maxRadius
                    ))
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(.rect)
        .gesture(dragGesture)
        .onTapGesture(coordinateSpace: .local, perform: handleTap)
        .onChange(of: spreadIndex) {
            // Index changed from outside (e.g. a slider) mid-drag: the turn no longer matches.
            if !isSettling { turn = nil }
        }
    }

    // MARK: - Layout

    private func pagePair(left: Int, right: Int) -> some View {
        HStack(spacing: 0) {
            page(left, .left)
                .frame(width: pageSize.width, height: pageSize.height)
            page(right, .right)
                .frame(width: pageSize.width, height: pageSize.height)
        }
    }

    /// Pages lying still under the turning sheet.
    private var basePages: (left: Int, right: Int) {
        switch turn?.direction {
        case nil: (leftIndex, rightIndex)
        case .forward: (leftIndex, rightIndex + 2)
        case .backward: (leftIndex - 2, rightIndex)
        }
    }

    /// The turning sheet: its front on its own half, its back on the other half.
    private func sheetPages(for direction: Turn.Direction) -> (left: Int, right: Int) {
        switch direction {
        case .forward: (rightIndex + 1, rightIndex)
        case .backward: (leftIndex, leftIndex - 1)
        }
    }

    private func sheetRect(for direction: Turn.Direction) -> CGRect {
        let x = direction == .forward ? spineX : 0
        return CGRect(x: x, y: 0, width: pageSize.width, height: pageSize.height)
    }

    /// Mirror of `corner` about the spine: where it lands once the page is turned.
    private func finish(for corner: CGPoint) -> CGPoint {
        CGPoint(x: 2 * spineX - corner.x, y: corner.y)
    }

    // MARK: - Drag

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged(handleDragChanged)
            .onEnded(handleDragEnded)
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        guard !isSettling else { return }
        if turn == nil {
            turn = makeTurn(for: value)
        }
        guard var active = turn else { return }
        active.target = dragTarget(for: value, turn: active)
        turn = active
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        guard let active = turn, !isSettling else { return }
        let predicted = value.predictedEndTranslation.width
        let threshold = pageSize.width * 0.3
        let completes = active.direction == .forward ? predicted < -threshold : predicted > threshold
        let animation = Animation.spring(duration: 0.5, bounce: 0)

        if completes {
            settle([(finish(for: active.corner), animation)]) {
                spreadIndex = spread + (active.direction == .forward ? 1 : -1)
            }
        } else {
            settle([(active.corner, animation)]) {}
        }
    }

    private func makeTurn(for value: DragGesture.Value) -> Turn? {
        let dx = value.translation.width
        let y = cornerY(forTouchAt: value.startLocation.y)
        let onRightPage = value.startLocation.x > spineX

        if dx < 0, onRightPage, canTurnForward {
            let corner = CGPoint(x: size.width, y: y)
            return Turn(direction: .forward, corner: corner, target: corner)
        }
        if dx > 0, !onRightPage, canTurnBackward {
            let corner = CGPoint(x: 0, y: y)
            return Turn(direction: .backward, corner: corner, target: corner)
        }
        return nil
    }

    /// Grabbing near the top or bottom edge lifts the real corner of the page.
    private func cornerY(forTouchAt y: CGFloat) -> CGFloat {
        if y < size.height * 0.18 { return 0 }
        if y > size.height * 0.82 { return size.height }
        return y
    }

    private func dragTarget(for value: DragGesture.Value, turn: Turn) -> CGPoint {
        // The grabbed point follows the finger.
        var point = CGPoint(x: turn.corner.x + value.translation.width, y: turn.corner.y + value.translation.height)
        switch turn.direction {
        case .forward: point.x = min(max(point.x, 0), turn.corner.x)
        case .backward: point.x = max(min(point.x, size.width), turn.corner.x)
        }
        point = CurlGeometry.limitingTilt(point, corner: turn.corner)
        let spineEnds = [CGPoint(x: spineX, y: 0), CGPoint(x: spineX, y: size.height)]
        return CurlGeometry.keepingSpineAttached(point, corner: turn.corner, spineEnds: spineEnds)
    }

    // MARK: - Tap

    private func handleTap(_ location: CGPoint) {
        guard !isSettling, turn == nil else { return }
        let edge = pageSize.width * 0.28
        if location.x > size.width - edge {
            turnPage(.forward)
        } else if location.x < edge {
            turnPage(.backward)
        } else {
            onTapCenter()
        }
    }

    private func turnPage(_ direction: Turn.Direction) {
        switch direction {
        case .forward: guard canTurnForward else { return }
        case .backward: guard canTurnBackward else { return }
        }

        // Lift the bottom corner toward the spine, then lay it down on the other side.
        let corner = CGPoint(x: direction == .forward ? size.width : 0, y: size.height)
        let liftX = direction == .forward ? spineX + pageSize.width * 0.25 : spineX - pageSize.width * 0.25
        let lift = CGPoint(x: liftX, y: size.height * 0.86)
        let finish = finish(for: corner)

        turn = Turn(direction: direction, corner: corner, target: corner)
        isSettling = true

        // Let the starting state commit first so the animation has a from-value.
        DispatchQueue.main.async {
            settle([(lift, .easeIn(duration: 0.32)), (finish, .easeOut(duration: 0.42))]) {
                spreadIndex = spread + (direction == .forward ? 1 : -1)
            }
        }
    }

    // MARK: - Settle

    /// Animates the turn through `steps`, then applies `onFinish` and clears the turn.
    private func settle(_ steps: [(target: CGPoint, animation: Animation)], onFinish: @escaping () -> Void) {
        guard let step = steps.first else {
            onFinish()
            turn = nil
            isSettling = false
            return
        }
        isSettling = true
        withAnimation(step.animation, completionCriteria: .removed) {
            turn?.target = step.target
        } completion: {
            settle(Array(steps.dropFirst()), onFinish: onFinish)
        }
    }
}

private struct Turn {
    enum Direction { case forward, backward }

    let direction: Direction
    /// Outer page point being dragged; the page is flat when `target == corner`.
    let corner: CGPoint
    var target: CGPoint
}
