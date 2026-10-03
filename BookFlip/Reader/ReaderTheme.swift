//
//  ReaderTheme.swift
//  BookFlip
//

import SwiftUI
import UIKit

enum ReaderTheme: String, CaseIterable, Identifiable {
    case paper
    case sepia
    case night

    var id: String { rawValue }

    var name: String {
        switch self {
        case .paper: "Giấy"
        case .sepia: "Sepia"
        case .night: "Đêm"
        }
    }

    var paperColor: UIColor {
        switch self {
        case .paper: UIColor(hex: 0xFBF8F1)
        case .sepia: UIColor(hex: 0xF2E4C7)
        case .night: UIColor(hex: 0x1C1B1A)
        }
    }

    var inkColor: UIColor {
        switch self {
        case .paper: UIColor(hex: 0x2A2622)
        case .sepia: UIColor(hex: 0x4A3A28)
        case .night: UIColor(hex: 0xCFCAC2)
        }
    }

    var secondaryInkColor: UIColor {
        switch self {
        case .paper: UIColor(hex: 0x8C847A)
        case .sepia: UIColor(hex: 0x8F7655)
        case .night: UIColor(hex: 0x7D786F)
        }
    }

    /// Paper color seen on the back of a curling page.
    var backColor: UIColor {
        switch self {
        case .paper: UIColor(hex: 0xF1EDE4)
        case .sepia: UIColor(hex: 0xE6D6B6)
        case .night: UIColor(hex: 0x2A2826)
        }
    }

    var grainStrength: Float {
        switch self {
        case .paper: 0.05
        case .sepia: 0.08
        case .night: 0.12
        }
    }

    var spineShadowOpacity: Double {
        self == .night ? 0.35 : 0.10
    }

    var colorScheme: ColorScheme {
        self == .night ? .dark : .light
    }
}

struct ReaderSettings: Equatable {
    static let fontSizeRange: ClosedRange<CGFloat> = 15...28

    var fontSize: CGFloat = 19
    var theme: ReaderTheme = .paper
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
