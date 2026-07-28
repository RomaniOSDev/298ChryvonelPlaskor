import SwiftUI

struct EventHistoryView: View {
    @ObservedObject var store: DataStore
    @ObservedObject var viewModel: LibraryViewModel

    var body: some View {
        if viewModel.isEmpty {
            EmptyStateView(
                message: "Start tracking your book journey!",
                systemImage: "book.circle"
            )
        } else {
            List {
                ForEach(viewModel.historyEvents) { event in
                    Button {
                        viewModel.selectedEvent = event
                        HapticService.light()
                    } label: {
                        HStack(spacing: 12) {
                            Image("stackBooks")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipped()
                                .cornerRadius(2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(event.bookName)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text(event.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .onMove(perform: viewModel.reorder)
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))
        }
    }
}
