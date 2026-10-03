//
//  PageCurlEffect.swift
//  BookFlip
//

import SwiftUI

/// Applies the Metal page-curl shader. `target` is animatable so the curl can
/// be driven by SwiftUI animations after the finger is lifted.
struct PageCurlEffect: ViewModifier, Animatable {
    var corner: CGPoint
    var target: CGPoint
    var maxRadius: CGFloat
    var backColor: Color

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(target.x, target.y) }
        set { target = CGPoint(x: newValue.first, y: newValue.second) }
    }

    func body(content: Content) -> some View {
        let geometry = CurlGeometry(corner: corner, target: target, maxRadius: maxRadius)
        // Flatten the page into a single texture first; otherwise the shader runs
        // per display-list item and the translucent shadow is blended several times.
        content
            .drawingGroup()
            .layerEffect(
                ShaderLibrary.pageCurl(
                    .boundingRect,
                    .float2(geometry.origin),
                    .float2(geometry.normal.dx, geometry.normal.dy),
                    .float(geometry.radius),
                    .float(geometry.shadowWidth),
                    .color(backColor)
                ),
                maxSampleOffset: .zero,
                isEnabled: geometry.isCurled
            )
    }
}

extension PageCurlEffect {
    static func flat(maxRadius: CGFloat, backColor: Color) -> PageCurlEffect {
        PageCurlEffect(corner: .zero, target: .zero, maxRadius: maxRadius, backColor: backColor)
    }
}
