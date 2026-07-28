import SwiftUI

struct TimelineSpineRow: View {
    let event: BookEvent
    let isFirst: Bool
    let isLast: Bool
    var linkedTitles: [String] = []
    let onTap: () -> Void

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: event.date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(isFirst ? Color.clear : Color("AppPrimary").opacity(0.45))
                    .frame(width: 2, height: 10)
                Circle()
                    .fill(Color("AppPrimary"))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color("AppAccent"), lineWidth: 1.5))
                    .shadow(color: Color("AppPrimary").opacity(0.5), radius: 4)
                Rectangle()
                    .fill(isLast ? Color.clear : Color("AppPrimary").opacity(0.45))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 16)

            Button(action: onTap) {
                ManuscriptCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.leading)
                        Text(dateText)
                            .font(.caption)
                            .foregroundStyle(Color("AppPrimary"))
                        if !event.description.isEmpty {
                            Text(event.description)
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        if !event.tags.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(event.tags.prefix(4), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .foregroundStyle(Color("AppBackground"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color("AppAccent").opacity(0.9))
                                        .cornerRadius(2)
                                }
                            }
                        }
                        if !event.links.isEmpty || !event.quotes.isEmpty {
                            HStack(spacing: 10) {
                                if !event.links.isEmpty {
                                    Label("\(event.links.count)", systemImage: "arrow.triangle.branch")
                                }
                                if !event.quotes.isEmpty {
                                    Label("\(event.quotes.count)", systemImage: "quote.opening")
                                }
                            }
                            .font(.caption2)
                            .foregroundStyle(Color("AppPrimary"))
                        }
                        if !linkedTitles.isEmpty {
                            Text(linkedTitles.map { "→ \($0)" }.joined(separator: "  "))
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                        }
                        Text(event.bookName)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, 4)
    }
}
