//
//  PageCurl.metal
//  BookFlip
//
//  Page curl modelled as a sheet of paper wrapping around a cylinder.
//
//  The fold line goes through `origin`; `normal` points from the fold toward the
//  lifted edge. A point of the sheet at distance `s` beyond the fold is projected to:
//    s <= 0         : flat on the table (front side up)
//    0 < s <= πr    : wrapped around the cylinder, x = r·sin(s/r)
//    s > πr         : lying flat on top of the cylinder (back side up), x = πr - s
//  For every screen pixel we invert that mapping and pick the top-most layer.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

namespace curl {

/// How the back of the sheet looks.
struct BackSide {
    /// true: the back is another page, stored in the layer mirrored about `spineX`.
    /// false: the back is plain `paper` with the front print faintly showing through.
    bool isPage;
    half4 paper;
    float spineX;
};

/// Signed distance from `p` to `rect` (x, y, width, height). Negative inside.
float sdRect(float2 p, float4 rect) {
    float2 halfSize = rect.zw * 0.5;
    float2 q = abs(p - (rect.xy + halfSize)) - halfSize;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

/// Anti-aliased coverage of a sheet whose edge is `sd` points away.
float coverage(float sd) {
    return saturate(0.5 - sd);
}

/// Contact-shadow falloff, 1 at the sheet edge and 0 at `width` points away.
/// It drops right from the edge (no plateau), so the shadow hugs the paper
/// instead of reading as a wide grey band.
float castShadow(float lateral, float away, float width) {
    float distance = length(max(float2(lateral, away), 0.0));
    float falloff = 1.0 - saturate(distance / width);
    return falloff * falloff * falloff;
}

/// Color of the back of the sheet at sheet point `source`.
half4 back(SwiftUI::Layer layer, float2 source, BackSide side, float light) {
    // Print on the front, seen from behind (mirrored for free since we sample at `source`).
    half4 showThrough = layer.sample(source);
    half3 base;
    half bleed;
    if (side.isPage) {
        base = layer.sample(float2(2.0 * side.spineX - source.x, source.y)).rgb;
        bleed = 0.06h;
    } else {
        base = side.paper.rgb;
        bleed = 0.12h;
    }
    return half4(mix(base, showThrough.rgb, bleed) * half(light), 1.0h);
}

half4 render(float2 position, SwiftUI::Layer layer, float4 sheet,
             float2 origin, float2 normal, float radius, float shadowWidth, BackSide side)
{
    const float pi = M_PI_F;
    const float r = max(radius, 0.0001);
    const float width = max(shadowWidth, 0.001);
    const float d = dot(position - origin, normal);

    if (d < 0.0) {
        // Not lifted. Inside the sheet this is its flat front; outside (the other half of
        // a spread) it is whatever lies below. The part of the sheet that wrapped over the
        // cylinder may lie on top, back side up.
        float2 source = position + normal * (pi * r - 2.0 * d);
        float edge = sdRect(source, sheet);
        // The turned-over part lies close to the page, so its shadow is a thin rim.
        float shadow = 0.22 * castShadow(max(edge, 0.0), 0.0, width * 0.5);

        half4 front = layer.sample(position) * half(coverage(sdRect(position, sheet)));
        half4 color = half4(front.rgb * half(1.0 - shadow), front.a)
                    + half4(0.0h, 0.0h, 0.0h, half(shadow)) * (1.0h - front.a);

        half4 top = back(layer, source, side, 1.0);
        return mix(color, top, half(coverage(edge)));
    }

    // Uncovered area reveals the page below, darkened by the curl's shadow.
    // Distance is measured from the cylinder's rim (θ = π/2).
    float2 rimSource = position + normal * (pi * r * 0.5 - d);
    float rimEdge = max(sdRect(rimSource, sheet), 0.0);
    float shadow = 0.4 * castShadow(rimEdge, d - r, width);
    half4 color = half4(0.0h, 0.0h, 0.0h, half(shadow));

    if (d <= r) {
        float theta = asin(saturate(d / r));

        // Lower half of the cylinder: the printed front, bending away from the viewer.
        float2 frontSource = position + normal * (r * theta - d);
        half4 front = layer.sample(frontSource);
        float frontLight = 0.72 + 0.28 * cos(theta);
        half4 lower = half4(front.rgb * half(frontLight), front.a)
                    * half(coverage(sdRect(frontSource, sheet)));
        color = lower + color * (1.0h - lower.a);

        // Upper half of the cylinder: the back of the sheet, facing the viewer.
        float2 backSource = position + normal * (r * (pi - theta) - d);
        float glint = (theta - 0.45) * 4.0;
        float backLight = 0.68 + 0.32 * cos(theta) + 0.08 * exp(-glint * glint);
        half4 upper = back(layer, backSource, side, backLight)
                    * half(coverage(sdRect(backSource, sheet)));
        color = upper + color * (1.0h - upper.a);
    }

    return color;
}

} // namespace curl

/// Single page: the whole layer is the sheet, its back is plain paper.
[[ stitchable ]]
half4 pageCurl(float2 position,
               SwiftUI::Layer layer,
               float4 bounds,
               float2 origin,
               float2 normal,
               float radius,
               float shadowWidth,
               half4 backColor)
{
    curl::BackSide side = { false, backColor, 0.0 };
    return curl::render(position, layer, bounds, origin, normal, radius, shadowWidth, side);
}

/// Two-page spread: `sheet` is the half that turns around the spine at `spineX`.
/// The other half of the layer holds the page printed on the back of the sheet; it is
/// only read (mirrored about the spine), never drawn where it is.
[[ stitchable ]]
half4 spreadCurl(float2 position,
                 SwiftUI::Layer layer,
                 float4 sheet,
                 float spineX,
                 float2 origin,
                 float2 normal,
                 float radius,
                 float shadowWidth)
{
    curl::BackSide side = { true, half4(1.0h), spineX };
    return curl::render(position, layer, sheet, origin, normal, radius, shadowWidth, side);
}
