import SwiftUI

struct ExhibitionDetailView: View {
    let exhibition: Exhibition
    @State private var isDescriptionExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exhibition.title)
                    .font(.system(size: 28, weight: .bold))

                if !exhibition.dateRange.isEmpty {
                    Text(exhibition.dateRange)
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }

                if let primaryText = exhibition.primaryText, !primaryText.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(primaryText.strippingHTML())
                            .lineLimit(isDescriptionExpanded ? nil : 6)
                            .animation(.easeInOut, value: isDescriptionExpanded)
                        Button {
                            withAnimation(.easeInOut) {
                                isDescriptionExpanded.toggle()
                            }
                        } label: {
                            Text(isDescriptionExpanded ? "Show less" : "Read more")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(exhibition.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
