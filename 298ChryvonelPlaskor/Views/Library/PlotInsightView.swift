import SwiftUI

struct PlotInsightView: View {
    @ObservedObject var viewModel: LibraryViewModel

    var body: some View {
        if viewModel.isEmpty {
            EmptyStateView(
                message: "No events yet",
                systemImage: "chart.bar.doc.horizontal"
            )
        } else {
            VStack(spacing: 16) {
                Picker("Segment", selection: $viewModel.segment) {
                    ForEach(InsightSegment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .onChange(of: viewModel.segment) { _ in
                    HapticService.light()
                    SoundService.tap()
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.insightGroups) { group in
                            ManuscriptCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(group.name)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        Text("\(group.count)")
                                            .font(.system(.title2, design: .serif))
                                            .foregroundStyle(Color("AppPrimary"))
                                    }

                                    GeometryReader { geo in
                                        let maxCount = max(viewModel.insightGroups.map(\.count).max() ?? 1, 1)
                                        let width = geo.size.width * CGFloat(group.count) / CGFloat(maxCount)
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color("AppBackground").opacity(0.55))
                                                .frame(height: 10)
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: max(width, 10), height: 10)
                                        }
                                    }
                                    .frame(height: 10)

                                    Text(countLabel(group.count))
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func countLabel(_ count: Int) -> String {
        count == 1 ? "1 event recorded" : "\(count) events recorded"
    }
}
