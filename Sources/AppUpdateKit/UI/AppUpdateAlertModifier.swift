#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI View Modifier that presents update alerts according to AppUpdateAction.
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AppUpdateAlertModifier: ViewModifier {
    @Binding public var action: AppUpdateAction
    public var onDismiss: (() -> Void)?
    @Environment(\.openURL) private var openURL

    public init(
        action: Binding<AppUpdateAction>,
        onDismiss: (() -> Void)? = nil
    ) {
        self._action = action
        self.onDismiss = onDismiss
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: {
                switch action {
                case .none:
                    return false
                case .optionalUpdate, .forceUpdate, .maintenance:
                    return true
                }
            },
            set: { isPresenting in
                if !isPresenting {
                    if case .forceUpdate = action {
                        // ponytail: forceUpdate requires update action, alert cannot be dismissed
                    } else {
                        action = .none
                        onDismiss?()
                    }
                }
            }
        )
    }

    public func body(content: Content) -> some View {
        content
            .alert(isPresented: isPresented) {
                switch action {
                case .none:
                    return Alert(title: Text(""))

                case .optionalUpdate(let title, let message, let storeURL):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        primaryButton: .default(Text("Update")) {
                            openURL(storeURL)
                            action = .none
                            onDismiss?()
                        },
                        secondaryButton: .cancel(Text("Later")) {
                            action = .none
                            onDismiss?()
                        }
                    )

                case .forceUpdate(let title, let message, let storeURL):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text("Update")) {
                            openURL(storeURL)
                        }
                    )

                case .maintenance(let title, let message):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text("OK")) {
                            action = .none
                            onDismiss?()
                        }
                    )
                }
            }
    }
}

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public extension View {
    /// Attaches an update alert driven by `AppUpdateAction`.
    func appUpdateAlert(
        action: Binding<AppUpdateAction>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(AppUpdateAlertModifier(action: action, onDismiss: onDismiss))
    }
}
#endif
