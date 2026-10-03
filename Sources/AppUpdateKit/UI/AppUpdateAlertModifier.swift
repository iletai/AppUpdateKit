#if canImport(SwiftUI)
import SwiftUI

/// Configuration for alert buttons and localization.
public struct AppUpdateUIConfiguration: Sendable {
    public var updateButtonTitle: String
    public var laterButtonTitle: String
    public var dismissButtonTitle: String

    public init(
        updateButtonTitle: String = "Cập nhật",
        laterButtonTitle: String = "Để sau",
        dismissButtonTitle: String = "Đã hiểu"
    ) {
        self.updateButtonTitle = updateButtonTitle
        self.laterButtonTitle = laterButtonTitle
        self.dismissButtonTitle = dismissButtonTitle
    }
}

/// SwiftUI View Modifier that presents native update alerts according to AppUpdateAction.
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AppUpdateAlertModifier: ViewModifier {
    @Binding public var action: AppUpdateAction
    public var configuration: AppUpdateUIConfiguration
    public var onDismiss: (() -> Void)?
    public var onEvent: ((AppUpdateEvent) -> Void)?
    @Environment(\.openURL) private var openURL

    public init(
        action: Binding<AppUpdateAction>,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        onDismiss: (() -> Void)? = nil,
        onEvent: ((AppUpdateEvent) -> Void)? = nil
    ) {
        self._action = action
        self.configuration = configuration
        self.onDismiss = onDismiss
        self.onEvent = onEvent
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: {
                switch action {
                case .none:
                    return false
                case .optionalUpdate, .forceUpdate, .maintenance, .custom:
                    return true
                }
            },
            set: { isPresenting in
                if !isPresenting {
                    if case .forceUpdate = action {
                        // forceUpdate cannot be dismissed by clicking outside
                    } else {
                        let prevAction = action
                        action = .none
                        onEvent?(.userAction(action: prevAction, choice: .dismiss))
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

                case .optionalUpdate(let title, let message, let storeURL, _, _, _):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        primaryButton: .default(Text(configuration.updateButtonTitle)) {
                            let currentAction = action
                            onEvent?(.userAction(action: currentAction, choice: .update(url: storeURL)))
                            openURL(storeURL)
                            action = .none
                            onDismiss?()
                        },
                        secondaryButton: .cancel(Text(configuration.laterButtonTitle)) {
                            let currentAction = action
                            onEvent?(.userAction(action: currentAction, choice: .remindLater))
                            action = .none
                            onDismiss?()
                        }
                    )

                case .forceUpdate(let title, let message, let storeURL, _, _, _):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text(configuration.updateButtonTitle)) {
                            let currentAction = action
                            onEvent?(.userAction(action: currentAction, choice: .update(url: storeURL)))
                            openURL(storeURL)
                        }
                    )

                case .maintenance(let title, let message, _):
                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text(configuration.dismissButtonTitle)) {
                            let currentAction = action
                            onEvent?(.userAction(action: currentAction, choice: .dismiss))
                            action = .none
                            onDismiss?()
                        }
                    )

                case .custom(let id, let title, let message, let storeURL, _, _, _):
                    if let storeURL = storeURL {
                        return Alert(
                            title: Text(title ?? ""),
                            message: Text(message ?? ""),
                            primaryButton: .default(Text(configuration.updateButtonTitle)) {
                                let currentAction = action
                                onEvent?(.userAction(action: currentAction, choice: .custom(id: id)))
                                openURL(storeURL)
                                action = .none
                                onDismiss?()
                            },
                            secondaryButton: .cancel(Text(configuration.laterButtonTitle)) {
                                let currentAction = action
                                onEvent?(.userAction(action: currentAction, choice: .dismiss))
                                action = .none
                                onDismiss?()
                            }
                        )
                    } else {
                        return Alert(
                            title: Text(title ?? ""),
                            message: Text(message ?? ""),
                            dismissButton: .default(Text(configuration.dismissButtonTitle)) {
                                let currentAction = action
                                onEvent?(.userAction(action: currentAction, choice: .custom(id: id)))
                                action = .none
                                onDismiss?()
                            }
                        )
                    }
                }
            }
            .onChange(of: action) { newAction in
                if newAction != .none {
                    onEvent?(.presented(action: newAction))
                }
            }
    }
}

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public extension View {
    /// Attaches an update alert driven by `AppUpdateAction`.
    func appUpdateAlert(
        action: Binding<AppUpdateAction>,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        onDismiss: (() -> Void)? = nil,
        onEvent: ((AppUpdateEvent) -> Void)? = nil
    ) -> some View {
        modifier(
            AppUpdateAlertModifier(
                action: action,
                configuration: configuration,
                onDismiss: onDismiss,
                onEvent: onEvent
            )
        )
    }
}
#endif
