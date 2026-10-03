//
//  CurlGeometry.swift
//  BookFlip
//

import CoreGraphics

/// Converts "the page point `corner` is dragged to `target`" into the
/// fold line and cylinder radius consumed by the shaders in PageCurl.metal.
nonisolated struct CurlGeometry {
    /// Point on the fold line where the cylinder touches the page.
    let origin: CGPoint
    /// Unit vector perpendicular to the fold, pointing toward the lifted edge.
    let normal: CGVector
    let radius: CGFloat
    let shadowWidth: CGFloat
    let isCurled: Bool

    /// Single page: the radius grows with the drag up to `maxRadius`, so the curl starts from a flat page.
    init(corner: CGPoint, target: CGPoint, maxRadius: CGFloat) {
        self.init(corner: corner, target: target, radius: maxRadius)
    }

    /// - Parameters:
    ///   - wantedRadius: cylinder radius; capped so that `corner` still lands exactly on `target`.
    ///   - shadowScale: multiplies the shadow width (spreads fade it out as the page lands).
    ///   - restingNormal: fold direction used while the page lies flat.
    init(
        corner: CGPoint,
        target: CGPoint,
        radius wantedRadius: CGFloat,
        shadowScale: CGFloat = 1,
        restingNormal: CGVector = CGVector(dx: 1, dy: 0)
    ) {
        let dx = corner.x - target.x
        let dy = corner.y - target.y
        let distance = hypot(dx, dy)

        guard distance > 0.5 else {
            // Fold just beyond the corner: the whole sheet lies flat.
            normal = restingNormal
            origin = CGPoint(x: corner.x + restingNormal.dx, y: corner.y + restingNormal.dy)
            radius = 0
            shadowWidth = 0
            isCurled = false
            return
        }

        normal = CGVector(dx: dx / distance, dy: dy / distance)
        radius = min(wantedRadius, distance / .pi)
        shadowWidth = Self.shadowWidth(forRadius: radius) * shadowScale
        // `corner` sits on the flat back part, so it lands exactly on `target` when
        // the fold is (distance + πr) / 2 away from it.
        let foldOffset = (distance + .pi * radius) / 2
        origin = CGPoint(x: corner.x - normal.dx * foldOffset, y: corner.y - normal.dy * foldOffset)
        isCurled = true
    }

    /// Paper stays close to the page below, so the shadow only grows a little with the
    /// curl and is capped: large spread radii (iPad) would otherwise smear it far out.
    static func shadowWidth(forRadius radius: CGFloat) -> CGFloat {
        min(radius * 0.4 + 6, 36)
    }

    /// Target far enough along `direction` that the curled page, its cylinder
    /// and its shadow have all left a page of `size`.
    static func hiddenTarget(corner: CGPoint, direction: CGVector, in size: CGSize, maxRadius: CGFloat) -> CGPoint {
        let length = hypot(direction.dx, direction.dy)
        let unit = length > 0
            ? CGVector(dx: direction.dx / length, dy: direction.dy / length)
            : CGVector(dx: -1, dy: 0)
        let normal = CGVector(dx: -unit.dx, dy: -unit.dy)

        let pageCorners = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: size.width, y: 0),
            CGPoint(x: 0, y: size.height),
            CGPoint(x: size.width, y: size.height),
        ]
        let nearest = pageCorners
            .map { ($0.x - corner.x) * normal.dx + ($0.y - corner.y) * normal.dy }
            .min() ?? 0

        // Every page point must end up more than r + shadowWidth beyond the fold.
        let radius = maxRadius
        let travel = 2 * (radius + shadowWidth(forRadius: radius) - nearest) - .pi * radius + 2
        return CGPoint(x: corner.x + unit.dx * travel, y: corner.y + unit.dy * travel)
    }

    // MARK: - Drag constraints

    /// Keeps the fold within ±45° of vertical.
    static func limitingTilt(_ point: CGPoint, corner: CGPoint) -> CGPoint {
        let run = abs(corner.x - point.x)
        return CGPoint(x: point.x, y: corner.y + min(max(point.y - corner.y, -run), run))
    }

    /// Folding preserves distances, so the spine stays put only while the target is
    /// no farther from each spine end than the grabbed corner is.
    static func keepingSpineAttached(_ point: CGPoint, corner: CGPoint, spineEnds: [CGPoint]) -> CGPoint {
        var result = point
        for anchor in spineEnds {
            let limit = hypot(corner.x - anchor.x, corner.y - anchor.y)
            let distance = hypot(result.x - anchor.x, result.y - anchor.y)
            if distance > limit {
                let scale = limit / distance
                result = CGPoint(x: anchor.x + (result.x - anchor.x) * scale, y: anchor.y + (result.y - anchor.y) * scale)
            }
        }
        return result
    }
}
