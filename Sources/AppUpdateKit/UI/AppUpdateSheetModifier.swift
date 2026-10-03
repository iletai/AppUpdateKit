#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI View Modifier that presents a customizable bottom sheet or modal view.
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AppUpdateSheetModifier: ViewModifier {
    @Binding public var action: AppUpdateAction
    public var configuration: AppUpdateUIConfiguration
    public var accentColor: Color
    public var onDismiss: (() -> Void)?
    public var onEvent: ((AppUpdateEvent) -> Void)?

    public init(
        action: Binding<AppUpdateAction>,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        accentColor: Color = .blue,
        onDismiss: (() -> Void)? = nil,
        onEvent: ((AppUpdateEvent) -> Void)? = nil
    ) {
        self._action = action
        self.configuration = configuration
        self.accentColor = accentColor
        self.onDismiss = onDismiss
        self.onEvent = onEvent
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: { action != .none },
            set: { isPresenting in
                if !isPresenting {
                    if case .forceUpdate = action {
                        // forceUpdate cannot be dismissed
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
            .sheet(isPresented: isPresented) {
                AppUpdateCardView(
                    action: action,
                    configuration: configuration,
                    accentColor: accentColor,
                    onAction: { choice in
                        let currentAction = action
                        onEvent?(.userAction(action: currentAction, choice: choice))
                        if case .update = choice {
                            if !currentAction.isBlocking {
                                action = .none
                                onDismiss?()
                            }
                        } else {
                            action = .none
                            onDismiss?()
                        }
                    }
                )
                .padding()
            }
    }
}

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public extension View {
    /// Presents a rich SwiftUI update sheet with release notes and custom styling.
    func appUpdateSheet(
        action: Binding<AppUpdateAction>,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        accentColor: Color = .blue,
        onDismiss: (() -> Void)? = nil,
        onEvent: ((AppUpdateEvent) -> Void)? = nil
    ) -> some View {
        modifier(
            AppUpdateSheetModifier(
                action: action,
                configuration: configuration,
                accentColor: accentColor,
                onDismiss: onDismiss,
                onEvent: onEvent
            )
        )
    }
}
#endif
