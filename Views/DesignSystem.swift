import SwiftUI

enum AppTheme {
    static let sectionRadius: CGFloat = 8
    static let pageSpacing: CGFloat = 18
    static let panelSpacing: CGFloat = 12

    static let incomeColor = Color.green
    static let expenseColor = Color.red
    static let balanceColor = Color.blue
    static let budgetColor = Color.indigo
    static let neutralColor = Color.secondary
}

struct PageHeader: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var actionTitle: String?
    var actionSystemImage: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.sectionRadius)
                    .fill(.tint.opacity(0.16))
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let actionTitle, let actionSystemImage, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: actionSystemImage)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.bottom, 2)
    }
}

struct AppPanel<Content: View>: View {
    let title: String
    let systemImage: String
    var footer: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.panelSpacing) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: AppTheme.sectionRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionRadius)
                .strokeBorder(.separator.opacity(0.35))
        }
    }
}

struct FilterBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 12) {
            content
        }
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: AppTheme.sectionRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionRadius)
                .strokeBorder(.separator.opacity(0.35))
        }
        .padding([.horizontal, .top])
    }
}

struct StatusPill: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.13), in: Capsule())
            .foregroundStyle(color)
    }
}

struct EmptyState: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(message)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
