//
//  BookCoverView.swift
//  BookFlip
//

import SwiftUI

struct BookCoverView: View {
    enum Style {
        case thumbnail
        case page
    }

    let book: Book
    var style: Style = .thumbnail

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                LinearGradient(colors: [book.cover.top, book.cover.bottom], startPoint: .top, endPoint: .bottom)

                // Decorative rings around the emblem.
                ForEach(1..<4) { ring in
                    Circle()
                        .stroke(book.cover.accent.opacity(0.18 / Double(ring)), lineWidth: max(1, width * 0.004))
                        .frame(width: width * (0.35 + 0.22 * CGFloat(ring)))
                        .offset(y: -proxy.size.height * 0.08)
                }

                VStack(spacing: width * 0.05) {
                    Spacer()
                    Image(systemName: book.cover.symbol)
                        .font(.system(size: width * 0.2, weight: .ultraLight))
                        .foregroundStyle(book.cover.accent)
                        .shadow(color: book.cover.accent.opacity(0.6), radius: width * 0.05)
                    Spacer()
                    Text(book.title)
                        .font(.system(size: width * 0.095, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                    Rectangle()
                        .fill(book.cover.accent)
                        .frame(width: width * 0.14, height: max(1, width * 0.006))
                    Text(book.author.uppercased())
                        .font(.system(size: width * 0.036, weight: .semibold))
                        .kerning(width * 0.006)
                        .opacity(0.8)
                    if style == .page {
                        Text(book.synopsis)
                            .font(.system(size: width * 0.04, design: .serif))
                            .italic()
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                            .padding(.top, width * 0.04)
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, width * 0.1)
                .padding(.vertical, proxy.size.height * (style == .page ? 0.12 : 0.08))

                // Hinge of the binding.
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [.black.opacity(0.35), .white.opacity(0.12), .black.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 0.07)
                    Spacer()
                }
            }
        }
        .clipShape(.rect(cornerRadii: cornerRadii))
    }

    private var cornerRadii: RectangleCornerRadii {
        switch style {
        case .thumbnail: RectangleCornerRadii(topLeading: 3, bottomLeading: 3, bottomTrailing: 8, topTrailing: 8)
        case .page: RectangleCornerRadii()
        }
    }
}

#Preview {
    BookCoverView(book: .lighthouse)
        .frame(width: 180, height: 270)
}
