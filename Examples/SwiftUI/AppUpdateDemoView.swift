import SwiftUI
import AppUpdateKit

/// Interactive demonstration view showcasing all AppUpdateKit presentation modes and lifecycle events.
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AppUpdateDemoView: View {
    @StateObject private var updateManager = AppUpdateManager.shared
    @State private var currentAction: AppUpdateAction = .none
    @State private var presentationStyle: PresentationStyle = .alert
    @State private var eventLogs: [String] = []

    public enum PresentationStyle: String, CaseIterable, Identifiable {
        case alert = "Native Alert"
        case sheet = "Custom Card Sheet"

        public var id: String { rawValue }
    }

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Presentation Mode")) {
                    Picker("Style", selection: $presentationStyle) {
                        ForEach(PresentationStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Simulate Scenarios")) {
                    Button("1. Optional Update (With Release Notes)") {
                        simulateOptionalUpdate()
                    }

                    Button("2. Force Update (Mandatory)") {
                        simulateForceUpdate()
                    }
                    .foregroundColor(.red)

                    Button("3. Maintenance Mode") {
                        simulateMaintenance()
                    }
                    .foregroundColor(.orange)

                    Button("4. Up-to-Date App") {
                        simulateUpToDate()
                    }
                    .foregroundColor(.secondary)
                }

                Section(header: Text("Remote Fetcher Simulation")) {
                    Button("Fetch from Mock microCMS") {
                        Task {
                            await checkFromRemote()
                        }
                    }
                }

                Section(header: Text("Event / Analytics Log")) {
                    if eventLogs.isEmpty {
                        Text("No events emitted yet.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(eventLogs.reversed(), id: \.self) { log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
            }
            .navigationTitle("AppUpdateKit Demo")
            // Native Alert presentation
            .appUpdateAlert(
                action: presentationStyle == .alert ? $currentAction : .constant(.none),
                onEvent: handleEvent
            )
            // Custom Sheet presentation
            .appUpdateSheet(
                action: presentationStyle == .sheet ? $currentAction : .constant(.none),
                accentColor: .indigo,
                onEvent: handleEvent
            )
        }
    }

    // MARK: - Simulation Handlers

    private func simulateOptionalUpdate() {
        let storeURL = URL(string: "https://apps.apple.com/app/id123456789")!
        let config = AppUpdateConfig(
            minimumVersion: "1.0.0",
            latestVersion: "2.1.0",
            storeURL: storeURL,
            title: "Có bản cập nhật mới! 🎉",
            message: "Phiên bản 2.1.0 đã sẵn sàng với giao diện mới và sửa lỗi quan trọng.",
            releaseNotes: [
                "✨ Hỗ trợ giao diện Liquid Glass & Dark Mode",
                "⚡️ Tối ưu tốc độ khởi động nhanh hơn 40%",
                "🐛 Sửa lỗi đồng bộ dữ liệu khi offline"
            ]
        )

        currentAction = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
    }

    private func simulateForceUpdate() {
        let storeURL = URL(string: "https://apps.apple.com/app/id123456789")!
        let config = AppUpdateConfig(
            minimumVersion: "3.0.0",
            latestVersion: "3.0.0",
            storeURL: storeURL,
            title: "Yêu cầu cập nhật bắt buộc ⚠️",
            message: "Phiên bản bạn đang sử dụng không còn được hỗ trợ. Vui lòng cập nhật ngay để tiếp tục sử dụng dịch vụ.",
            releaseNotes: [
                "🔒 Nâng cấp giao thức bảo mật API v2",
                "⚙️ Thay đổi hạ tầng server"
            ]
        )

        currentAction = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
    }

    private func simulateMaintenance() {
        let config = AppUpdateConfig(
            isMaintenance: true,
            title: "Hệ thống bảo trì 🛠️",
            message: "Chúng tôi đang tiến hành bảo trì định kỳ từ 00:00 đến 04:00. Xin lỗi vì sự bất tiện này."
        )

        currentAction = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
    }

    private func simulateUpToDate() {
        let config = AppUpdateConfig(minimumVersion: "1.0.0", latestVersion: "1.0.0")
        currentAction = AppUpdateChecker.evaluate(currentVersion: "1.0.0", config: config)
        log("Evaluated: App is up to date (.none)")
    }

    private func checkFromRemote() async {
        // Simulated network fetch
        currentAction = await updateManager.check(
            policy: .always,
            currentVersion: "1.9.0",
            onEvent: handleEvent
        ) {
            try await Task.sleep(nanoseconds: 500_000_000)
            return AppUpdateConfig(
                minimumVersion: "1.5.0",
                latestVersion: "2.2.0",
                storeURL: URL(string: "https://apps.apple.com/app/id123456789"),
                releaseNotes: ["✨ Cập nhật từ microCMS endpoint"]
            )
        }
    }

    private func handleEvent(_ event: AppUpdateEvent) {
        switch event {
        case .checkStarted:
            log("🚀 Check started")
        case .configFetched(let config):
            log("📥 Config fetched (min: \(config.minimumVersion ?? "-"), latest: \(config.latestVersion ?? "-"))")
        case .evaluated(let action):
            log("⚖️ Evaluated: \(action)")
        case .presented(let action):
            log("🔔 Presented: \(action.title ?? "Update")")
        case .userAction(_, let choice):
            log("👤 User choice: \(choice)")
        case .checkFailed(let reason):
            log("❌ Check failed: \(reason)")
        }
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        eventLogs.append("[\(timestamp)] \(message)")
    }
}
