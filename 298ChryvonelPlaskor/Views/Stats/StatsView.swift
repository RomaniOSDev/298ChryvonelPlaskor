import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var store: DataStore

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                BannerHeader("Statistics", subtitle: "Your reading chronicle")

                ScrollView {
                    VStack(spacing: 14) {
                        summaryCard

                        if store.events.isEmpty {
                            ManuscriptCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("No data yet")
                                        .font(.system(.title3, design: .serif))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text("Add timeline events to see charts for themes, books, and activity.")
                                        .font(.system(.subheadline, design: .serif))
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        } else {
                            themesChartCard
                            booksChartCard
                            activityChartCard
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var summaryCard: some View {
        ManuscriptCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Overview")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color("AppTextPrimary"))
                GoldDivider()
                HStack {
                    summaryCell(title: "Events", value: "\(store.events.count)")
                    summaryCell(title: "Created", value: "\(store.stats.itemsCreated)")
                    summaryCell(title: "Streak", value: "\(store.stats.streakDays)d")
                    summaryCell(title: "Sessions", value: "\(store.stats.sessionsCompleted)")
                }
            }
        }
    }

    private var themesChartCard: some View {
        ManuscriptCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("By Theme")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color("AppTextPrimary"))
                GoldDivider()
                Chart(themeCounts, id: \.label) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Theme", item.label)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppAccent"), Color("AppPrimary")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: CGFloat(max(160, themeCounts.count * 36)))
            }
        }
    }

    private var booksChartCard: some View {
        ManuscriptCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("By Book")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color("AppTextPrimary"))
                GoldDivider()
                Chart(bookCounts, id: \.label) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Book", item.label)
                    )
                    .foregroundStyle(Color("AppAccent").opacity(0.85))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.25))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: CGFloat(max(160, bookCounts.count * 36)))
            }
        }
    }

    private var activityChartCard: some View {
        ManuscriptCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Activity (30 days)")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color("AppTextPrimary"))
                GoldDivider()
                Chart(activityCounts, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Events", item.count)
                    )
                    .foregroundStyle(Color("AppPrimary").opacity(item.count == 0 ? 0.15 : 0.9))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color("AppTextSecondary").opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(height: 180)
            }
        }
    }

    private func summaryCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private var themeCounts: [(label: String, count: Int)] {
        let grouped = Dictionary(grouping: store.events, by: \.theme)
        return grouped
            .map { (label: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var bookCounts: [(label: String, count: Int)] {
        let grouped = Dictionary(grouping: store.events, by: \.bookName)
        return grouped
            .map { (label: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(8)
            .map { $0 }
    }

    private var activityCounts: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -29, to: today) else { return [] }

        var buckets: [Date: Int] = [:]
        for offset in 0..<30 {
            if let day = calendar.date(byAdding: .day, value: offset, to: start) {
                buckets[day] = 0
            }
        }
        for event in store.events {
            let day = calendar.startOfDay(for: event.date)
            if buckets[day] != nil {
                buckets[day, default: 0] += 1
            }
        }
        return buckets
            .map { (date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }
}
