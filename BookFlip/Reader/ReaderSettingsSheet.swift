//
//  ReaderSettingsSheet.swift
//  BookFlip
//

import SwiftUI

struct ReaderSettingsSheet: View {
    @Binding var settings: ReaderSettings

    var body: some View {
        VStack(spacing: 24) {
            Text("Hiển thị")
                .font(.headline)

            HStack(spacing: 16) {
                fontButton(systemImage: "textformat.size.smaller", step: -1)
                Text("\(Int(settings.fontSize)) pt")
                    .font(.body.monospacedDigit())
                    .frame(minWidth: 64)
                fontButton(systemImage: "textformat.size.larger", step: 1)
            }

            HStack(spacing: 20) {
                ForEach(ReaderTheme.allCases) { theme in
                    themeButton(theme)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(250)])
        .presentationBackground(.regularMaterial)
    }

    private func fontButton(systemImage: String, step: CGFloat) -> some View {
        let next = settings.fontSize + step
        return Button {
            settings.fontSize = next
        } label: {
            Image(systemName: systemImage)
                .font(.title3)
                .frame(width: 52, height: 44)
        }
        .buttonStyle(.glass)
        .disabled(!ReaderSettings.fontSizeRange.contains(next))
    }

    private func themeButton(_ theme: ReaderTheme) -> some View {
        Button {
            settings.theme = theme
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color(theme.paperColor))
                    .overlay {
                        Text("Aa")
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(Color(theme.inkColor))
                    }
                    .overlay {
                        Circle().strokeBorder(settings.theme == theme ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: settings.theme == theme ? 3 : 1)
                    }
                    .frame(width: 54, height: 54)
                Text(theme.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
