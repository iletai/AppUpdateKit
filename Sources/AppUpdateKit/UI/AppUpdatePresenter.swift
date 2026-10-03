#if canImport(UIKit) && !os(watchOS)
import UIKit

/// Helper for presenting update alerts and handling user choices in UIKit apps.
@MainActor
public enum AppUpdatePresenter {
    /// Presents a native `UIAlertController` for the given `AppUpdateAction`.
    public static func present(
        action: AppUpdateAction,
        from viewController: UIViewController,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        animated: Bool = true,
        onEvent: ((AppUpdateEvent) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard action != .none else { return }

        let alert = UIAlertController(
            title: action.title,
            message: action.message,
            preferredStyle: .alert
        )

        switch action {
        case .none:
            return

        case .optionalUpdate(_, _, let storeURL, _, _, _):
            alert.addAction(UIAlertAction(title: configuration.laterButtonTitle, style: .cancel) { _ in
                onEvent?(.userAction(action: action, choice: .remindLater))
                completion?()
            })
            alert.addAction(UIAlertAction(title: configuration.updateButtonTitle, style: .default) { _ in
                onEvent?(.userAction(action: action, choice: .update(url: storeURL)))
                UIApplication.shared.open(storeURL)
                completion?()
            })

        case .forceUpdate(_, _, let storeURL, _, _, _):
            alert.addAction(UIAlertAction(title: configuration.updateButtonTitle, style: .default) { _ in
                onEvent?(.userAction(action: action, choice: .update(url: storeURL)))
                UIApplication.shared.open(storeURL)
            })

        case .maintenance:
            alert.addAction(UIAlertAction(title: configuration.dismissButtonTitle, style: .cancel) { _ in
                onEvent?(.userAction(action: action, choice: .dismiss))
                completion?()
            })

        case .custom(let id, _, _, let storeURL, _, _, _):
            if let storeURL = storeURL {
                alert.addAction(UIAlertAction(title: configuration.laterButtonTitle, style: .cancel) { _ in
                    onEvent?(.userAction(action: action, choice: .dismiss))
                    completion?()
                })
                alert.addAction(UIAlertAction(title: configuration.updateButtonTitle, style: .default) { _ in
                    onEvent?(.userAction(action: action, choice: .custom(id: id)))
                    UIApplication.shared.open(storeURL)
                    completion?()
                })
            } else {
                alert.addAction(UIAlertAction(title: configuration.dismissButtonTitle, style: .default) { _ in
                    onEvent?(.userAction(action: action, choice: .custom(id: id)))
                    completion?()
                })
            }
        }

        viewController.present(alert, animated: animated) {
            onEvent?(.presented(action: action))
        }
    }
}

public extension UIViewController {
    /// Presents an update alert driven by `AppUpdateAction`.
    func presentAppUpdate(
        action: AppUpdateAction,
        configuration: AppUpdateUIConfiguration = AppUpdateUIConfiguration(),
        animated: Bool = true,
        onEvent: ((AppUpdateEvent) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        AppUpdatePresenter.present(
            action: action,
            from: self,
            configuration: configuration,
            animated: animated,
            onEvent: onEvent,
            completion: completion
        )
    }
}
#endif
