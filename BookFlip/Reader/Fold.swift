//
//  Fold.swift
//  BookFlip
//

import SwiftUI

/// A band of the screen where the device folds (or is occluded by its hinge).
/// The reader never draws content inside it.
struct Fold: Equatable {
    enum Axis: Equatable {
        /// Splits the screen into a left and a right half: the book opens as a two-page spread.
        case vertical
        /// Splits the screen into a top and a bottom half: text flows around the band.
        case horizontal
    }

    let axis: Axis
    /// x-range of a vertical fold, y-range of a horizontal one, in the reader's full-screen coordinates.
    let range: ClosedRange<CGFloat>

    var length: CGFloat { range.upperBound - range.lowerBound }

    func rect(in size: CGSize) -> CGRect {
        switch axis {
        case .vertical: CGRect(x: range.lowerBound, y: 0, width: length, height: size.height)
        case .horizontal: CGRect(x: 0, y: range.lowerBound, width: size.width, height: length)
        }
    }

    /// The active fold reported by the system (iOS 27.1 reserved regions), if any.
    /// - Parameter origin: position of `proxy`'s origin in the reader's full-screen coordinates.
    static func detect(in proxy: GeometryProxy, origin: CGPoint, containerSize: CGSize) -> Fold? {
        #if compiler(>=6.4)
        if #available(iOS 27.1, *) {
            let regions = proxy.reservedRegions(kind: .division) + proxy.reservedRegions(kind: .occlusion)
            let frames = regions.map { $0.frame.offsetBy(dx: origin.x, dy: origin.y) }
            return fold(from: frames, in: containerSize)
        }
        #endif
        return nil
    }

    /// Keeps only bands crossing the whole screen; small occlusions (camera, sensors)
    /// are already covered by the safe area.
    static func fold(from frames: [CGRect], in size: CGSize) -> Fold? {
        let bounds = CGRect(origin: .zero, size: size)
        let bands = frames.map { $0.intersection(bounds) }.filter { !$0.isNull }

        let vertical = bands.filter { $0.height >= size.height * 0.5 && $0.width < size.width * 0.3 }
        if let band = vertical.dropFirst().reduce(vertical.first, { $0?.union($1) }) {
            return Fold(axis: .vertical, range: band.minX...band.maxX)
        }

        let horizontal = bands.filter { $0.width >= size.width * 0.5 && $0.height < size.height * 0.3 }
        if let band = horizontal.dropFirst().reduce(horizontal.first, { $0?.union($1) }) {
            return Fold(axis: .horizontal, range: band.minY...band.maxY)
        }
        return nil
    }
}
