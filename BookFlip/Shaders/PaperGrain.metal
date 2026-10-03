//
//  PaperGrain.metal
//  BookFlip
//
//  Subtle procedural paper texture: fine grain, horizontal fibers and soft clouds.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

namespace paper {

float hash(float2 p) {
    p = fract(p * float2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float valueNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

} // namespace paper

[[ stitchable ]]
half4 paperGrain(float2 position, half4 color, float strength) {
    float grain = paper::hash(floor(position * 2.0)) - 0.5;
    float fibers = paper::valueNoise(position * float2(0.04, 0.35)) - 0.5;
    float clouds = paper::valueNoise(position * 0.01) - 0.5;
    float variation = grain * 0.35 + fibers * 0.45 + clouds * 0.9;
    return half4(color.rgb * half(1.0 + variation * strength), color.a);
}
