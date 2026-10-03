#if canImport(UIKit) && !os(watchOS)
import UIKit
import AppUpdateKit

/// Sample UIViewController demonstrating UIKit integration with AppUpdateKit.
public class DemoViewController: UIViewController {
    private let actionButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForUpdates()
    }

    private func setupUI() {
        actionButton.setTitle("Kiểm tra cập nhật", for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(didTapCheck), for: .touchUpInside)

        view.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func didTapCheck() {
        checkForUpdates()
    }

    private func checkForUpdates() {
        Task { [weak self] in
            guard let self = self else { return }

            let fetcher = AppUpdateFetcher.json(
                url: URL(string: "https://raw.githubusercontent.com/iletai/AppUpdateKit/main/Example/config.json")!
            )

            let action = await AppUpdateChecker.check(
                onEvent: { event in
                    print("[AppUpdateKit Event] \(event)")
                },
                fetcher: fetcher
            )

            // Present native Alert
            self.presentAppUpdate(
                action: action,
                configuration: AppUpdateUIConfiguration(
                    updateButtonTitle: "Cập nhật",
                    laterButtonTitle: "Để sau",
                    dismissButtonTitle: "Đã hiểu"
                ),
                onEvent: { event in
                    // Track analytics (e.g. Firebase Analytics, Mixpanel)
                    if case .userAction(_, let choice) = event {
                        print("User tapped choice: \(choice)")
                    }
                }
            )
        }
    }
}
#endif
