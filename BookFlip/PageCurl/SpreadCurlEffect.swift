//
//  SpreadCurlEffect.swift
//  BookFlip
//

import SwiftUI

/// Turns one half of a two-page spread around the spine with the `spreadCurl` shader.
///
/// The content must be the whole spread: the half in `sheet` is the page being turned,
/// the other half holds the page printed on its back.
struct SpreadCurlEffect: ViewModifier, Animatable {
    var corner: CGPoint
    var target: CGPoint
    /// Where `corner` lands once the page lies flat on the other side.
    var finish: CGPoint
    var sheet: CGRect
    var spineX: CGFloat
    var maxRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(target.x, target.y) }
        set { target = CGPoint(x: newValue.first, y: newValue.second) }
    }

    func body(content: Content) -> some View {
        let geometry = makeGeometry()
        content
            .drawingGroup()
            .layerEffect(
                ShaderLibrary.spreadCurl(
                    .float4(sheet.minX, sheet.minY, sheet.width, sheet.height),
                    .float(spineX),
                    .float2(geometry.origin),
                    .float2(geometry.normal.dx, geometry.normal.dy),
                    .float(geometry.radius),
                    .float(geometry.shadowWidth)
                ),
                maxSampleOffset: .zero
            )
    }

    private func makeGeometry() -> CurlGeometry {
        let travel = hypot(finish.x - corner.x, finish.y - corner.y)
        let distance = hypot(target.x - corner.x, target.y - corner.y)
        let progress = travel > 0 ? min(distance / travel, 1) : 0
        // The page must be flat at both ends of the turn: the curl swells mid-way,
        // then the fold settles exactly on the spine.
        let swell = sin(.pi * progress)
        let restingNormal = CGVector(dx: corner.x > spineX ? 1 : -1, dy: 0)
        return CurlGeometry(
            corner: corner,
            target: target,
            radius: maxRadius * swell,
            shadowScale: swell,
            restingNormal: restingNormal
        )
    }
}
