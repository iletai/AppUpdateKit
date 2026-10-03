#if canImport(SwiftUI)
import SwiftUI

/// A customizable, modern card view presenting app update details and release notes.
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AppUpdateCardView: View {
    public let action: AppUpdateAction
    public var configuration: AppUpdateUIConfiguration
    public var accentColor: Color
    public var onAction: ((AppUpdateUserChoice) -> Void)?
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    public init(
        action: AppUpdateAction,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        accentColor: Color = .blue,
        onAction: ((AppUpdateUserChoice) -> Void)? = nil
    ) {
        self.action = action
        self.configuration = configuration
        self.accentColor = accentColor
        self.onAction = onAction
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Icon
            iconView

            // Title and Description
            VStack(spacing: 8) {
                if let title = action.title {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }

                if let message = action.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Release Notes / Changelog
            if let notes = action.releaseNotes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Có gì mới:")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(notes, id: \.self) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(accentColor)
                                Text(item)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Buttons
            VStack(spacing: 12) {
                if let storeURL = action.storeURL {
                    Button(action: {
                        if let customID = action.customID {
                            onAction?(.custom(id: customID))
                        } else {
                            onAction?(.update(url: storeURL))
                        }
                        openURL(storeURL)
                    }) {
                        Text(configuration.updateButtonTitle)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                if action.isMaintenance {
                    Button(action: {
                        onAction?(.dismiss)
                    }) {
                        Text(configuration.dismissButtonTitle)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                } else if !action.isRequired && action.isUpdateAvailable {
                    Button(action: {
                        onAction?(.remindLater)
                    }) {
                        Text(configuration.laterButtonTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(24)
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.98))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var iconView: some View {
        if action.isMaintenance {
            Image(systemName: "wrench.and.screwdriver.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.orange)
        } else if action.isRequired {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.red)
        } else {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(accentColor)
        }
    }
}
#endif
