//
//  PageCurlContainer.swift
//  BookFlip
//

import SwiftUI

/// Shows one page at a time and turns pages with a Metal page curl.
///
/// - Drag from right to left curls the current page away.
/// - Drag from left to right brings the previous page back.
/// - Tap the right / left edge to turn without dragging, tap the middle for `onTapCenter`.
struct PageCurlContainer<Page: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let size: CGSize
    var backColor: Color = .white
    var onTapCenter: () -> Void = {}
    @ViewBuilder let page: (Int) -> Page

    @State private var curl: Curl?
    @State private var isSettling = false

    private var maxRadius: CGFloat { min(size.width * 0.14, 64) }

    var body: some View {
        ZStack {
            ForEach(visibleIndices, id: \.self) { index in
                page(index)
                    .frame(width: size.width, height: size.height)
                    .modifier(effect(forPageAt: index))
                    .zIndex(index == curl?.pageIndex ? 1 : 0)
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(.rect)
        .gesture(dragGesture)
        .onTapGesture(coordinateSpace: .local, perform: handleTap)
        .onChange(of: currentIndex) {
            // Index changed from outside (e.g. a slider) mid-drag: the curl no longer matches the stack.
            if !isSettling { curl = nil }
        }
    }

    // MARK: - Layout

    /// Bottom page first, curled page last.
    private var visibleIndices: [Int] {
        guard pageCount > 0 else { return [] }
        let current = min(max(currentIndex, 0), pageCount - 1)
        guard let curl else { return [current] }
        switch curl.direction {
        case .forward: return [current + 1, current]
        case .backward: return [current, current - 1]
        }
    }

    private func effect(forPageAt index: Int) -> PageCurlEffect {
        guard let curl, curl.pageIndex == index else {
            return .flat(maxRadius: maxRadius, backColor: backColor)
        }
        return PageCurlEffect(corner: curl.corner, target: curl.target, maxRadius: maxRadius, backColor: backColor)
    }

    // MARK: - Drag

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged(handleDragChanged)
            .onEnded(handleDragEnded)
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        guard !isSettling else { return }
        if curl == nil {
            curl = makeCurl(for: value)
        }
        guard var active = curl else { return }
        active.target = dragTarget(for: value, curl: active)
        curl = active
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        guard let active = curl, !isSettling else { return }
        let predicted = value.predictedEndTranslation.width
        let threshold = size.width * 0.25
        let animation = Animation.spring(duration: 0.45, bounce: 0)

        switch active.direction {
        case .forward:
            guard predicted < -threshold else {
                settle(to: active.corner, animation: animation) {}
                return
            }
            // Keep the angle the finger was pulling at.
            let direction = CGVector(dx: active.target.x - active.corner.x, dy: active.target.y - active.corner.y)
            let hidden = CurlGeometry.hiddenTarget(corner: active.corner, direction: direction, in: size, maxRadius: maxRadius)
            settle(to: hidden, animation: animation) { currentIndex += 1 }
        case .backward:
            guard predicted > threshold else {
                settle(to: active.hiddenTarget, animation: animation) {}
                return
            }
            settle(to: active.corner, animation: animation) { currentIndex -= 1 }
        }
    }

    private func makeCurl(for value: DragGesture.Value) -> Curl? {
        let corner = CGPoint(x: size.width, y: cornerY(forTouchAt: value.startLocation.y))
        let hidden = CurlGeometry.hiddenTarget(corner: corner, direction: CGVector(dx: -1, dy: 0), in: size, maxRadius: maxRadius)
        let dx = value.translation.width

        if dx < 0, currentIndex + 1 < pageCount {
            return Curl(direction: .forward, pageIndex: currentIndex, corner: corner, hiddenTarget: hidden, target: corner)
        }
        if dx > 0, currentIndex > 0 {
            return Curl(direction: .backward, pageIndex: currentIndex - 1, corner: corner, hiddenTarget: hidden, target: hidden)
        }
        return nil
    }

    /// Grabbing near the top or bottom edge lifts the real corner of the page.
    private func cornerY(forTouchAt y: CGFloat) -> CGFloat {
        if y < size.height * 0.18 { return 0 }
        if y > size.height * 0.82 { return size.height }
        return y
    }

    private func dragTarget(for value: DragGesture.Value, curl: Curl) -> CGPoint {
        var point: CGPoint
        switch curl.direction {
        case .forward:
            // The grabbed point follows the finger.
            point = CGPoint(x: curl.corner.x + value.translation.width, y: curl.corner.y + value.translation.height)
        case .backward:
            // A full-width drag brings the previous page from hidden back to flat.
            let travel = curl.corner.x - curl.hiddenTarget.x
            let progress = value.translation.width / size.width
            point = CGPoint(x: curl.hiddenTarget.x + travel * progress, y: curl.corner.y + value.translation.height * 0.5)
        }

        point.x = min(point.x, curl.corner.x)
        point = CurlGeometry.limitingTilt(point, corner: curl.corner)

        if curl.direction == .forward {
            let spineEnds = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: size.height)]
            point = CurlGeometry.keepingSpineAttached(point, corner: curl.corner, spineEnds: spineEnds)
        }
        return point
    }

    // MARK: - Tap

    private func handleTap(_ location: CGPoint) {
        guard !isSettling, curl == nil else { return }
        if location.x > size.width * 0.72 {
            turnPage(.forward)
        } else if location.x < size.width * 0.28 {
            turnPage(.backward)
        } else {
            onTapCenter()
        }
    }

    private func turnPage(_ direction: Curl.Direction) {
        // Lift the bottom corner slightly upward, like a thumb flicking the page.
        let corner = CGPoint(x: size.width, y: size.height)
        let hidden = CurlGeometry.hiddenTarget(corner: corner, direction: CGVector(dx: -1, dy: -0.18), in: size, maxRadius: maxRadius)
        let animation = Animation.easeInOut(duration: 0.7)

        switch direction {
        case .forward:
            guard currentIndex + 1 < pageCount else { return }
            curl = Curl(direction: .forward, pageIndex: currentIndex, corner: corner, hiddenTarget: hidden, target: corner)
        case .backward:
            guard currentIndex > 0 else { return }
            curl = Curl(direction: .backward, pageIndex: currentIndex - 1, corner: corner, hiddenTarget: hidden, target: hidden)
        }
        isSettling = true

        // Let the starting curl commit first so the animation has a from-value.
        DispatchQueue.main.async {
            switch direction {
            case .forward: settle(to: hidden, animation: animation) { currentIndex += 1 }
            case .backward: settle(to: corner, animation: animation) { currentIndex -= 1 }
            }
        }
    }

    // MARK: - Settle

    private func settle(to target: CGPoint, animation: Animation, onFinish: @escaping () -> Void) {
        isSettling = true
        withAnimation(animation, completionCriteria: .removed) {
            curl?.target = target
        } completion: {
            onFinish()
            curl = nil
            isSettling = false
        }
    }
}

private struct Curl {
    enum Direction { case forward, backward }

    let direction: Direction
    /// Page drawn on top with the curl applied.
    let pageIndex: Int
    /// Page point being dragged; the page is flat when `target == corner`.
    let corner: CGPoint
    /// Target at which the page has fully left the screen.
    let hiddenTarget: CGPoint
    var target: CGPoint
}
