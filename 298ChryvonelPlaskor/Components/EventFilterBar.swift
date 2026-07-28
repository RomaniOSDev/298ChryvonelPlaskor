import SwiftUI

struct EventFilterBar: View {
    @Binding var filter: EventFilter
    let bookNames: [String]
    let themes: [String]
    let tags: [String]
    @State private var showDates = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("AppTextSecondary"))
                TextField("Search events", text: $filter.query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundStyle(Color("AppTextPrimary"))
                if filter.isActive {
                    Button {
                        filter = EventFilter()
                        showDates = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color("AppSurface"))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 1)
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterMenu(title: "Book", selection: $filter.bookName, options: ["All"] + bookNames)
                    filterMenu(title: "Theme", selection: $filter.theme, options: ["All"] + themes)
                    filterMenu(title: "Tag", selection: $filter.tag, options: ["All"] + tags)
                    Button {
                        showDates.toggle()
                    } label: {
                        chipLabel(
                            text: (filter.dateFrom != nil || filter.dateTo != nil) ? "Date · On" : "Date",
                            active: filter.dateFrom != nil || filter.dateTo != nil || showDates
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if showDates {
                VStack(spacing: 8) {
                    DatePicker(
                        "From",
                        selection: Binding(
                            get: { filter.dateFrom ?? Date() },
                            set: { filter.dateFrom = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .foregroundStyle(Color("AppTextPrimary"))
                    DatePicker(
                        "To",
                        selection: Binding(
                            get: { filter.dateTo ?? Date() },
                            set: { filter.dateTo = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .foregroundStyle(Color("AppTextPrimary"))
                    HStack {
                        Button("Clear dates") {
                            filter.dateFrom = nil
                            filter.dateTo = nil
                        }
                        .font(.caption)
                        .foregroundStyle(Color("AppPrimary"))
                        Spacer()
                    }
                }
                .padding(10)
                .background(Color("AppSurface").opacity(0.85))
                .cornerRadius(4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color("AppSurface").opacity(0.45))
    }

    private func filterMenu(title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection.wrappedValue = option }
            }
        } label: {
            chipLabel(
                text: selection.wrappedValue == "All" ? title : "\(title): \(selection.wrappedValue)",
                active: selection.wrappedValue != "All"
            )
        }
    }

    private func chipLabel(text: String, active: Bool) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(active ? Color("AppBackground") : Color("AppTextSecondary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(active ? Color("AppPrimary") : Color("AppSurface"))
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
            )
            .cornerRadius(2)
    }
}
