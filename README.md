# AppUpdateKit

<p align="center">
  <img src="https://raw.githubusercontent.com/iletai/AppUpdateKit/main/art/banner.png" alt="AppUpdateKit Banner" width="100%" onerror="this.style.display='none'"/>
</p>

<p align="center">
  <a href="https://github.com/iletai/AppUpdateKit/actions"><img src="https://github.com/iletai/AppUpdateKit/workflows/Swift%20CI/badge.svg" alt="CI Status"></a>
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Platforms-iOS%2014+%20%7C%20macOS%2011+%20%7C%20watchOS%207+%20%7C%20tvOS%2014+-blue.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/Dependencies-0%20Zero-green.svg" alt="Zero Dependencies">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-black.svg" alt="License"></a>
</p>

**AppUpdateKit** is an ultra-lightweight, zero-dependency Swift Package for evaluating app versions, enforcing **Force Updates**, presenting **Optional Updates** (with release notes), and activating **Maintenance Mode** remotely via **microCMS**, **Raw JSON (GitHub Raw, S3, Cloudflare Workers)**, or any backend endpoint.

---

## 📱 Visual UI Preview

### 1. Native Alert vs. Custom Card Sheet

```
┌────────────────────────────────────────┐       ┌────────────────────────────────────────┐
│             Update Available           │       │             ╭────────────╮             │
│                                        │       │             │     🔄     │             │
│  A new version (2.1.0) is available on │       │             ╰────────────╯             │
│  the App Store. Would you like to get  │       │         Bản Cập Nhật Mới 2.1.0         │
│  the latest features?                  │       │  Trải nghiệm giao diện mới và sửa lỗi. │
│                                        │       │                                        │
│                                        │       │  ┌── Có gì mới: ────────────────────┐  │
│                                        │       │  │ • ✨ Giao diện Liquid Glass      │  │
│                                        │       │  │ • ⚡️ Tối ưu tốc độ tải 40%      │  │
│  ┌──────────────────┐┌───────────────┐ │       │  │ • 🐛 Sửa lỗi offline sync        │  │
│  │    Để sau (Later)││Cập nhật(Update│ │       │  └──────────────────────────────────┘  │
│  └──────────────────┘└───────────────┘ │       │  ┌──────────────────────────────────┐  │
│                                        │       │  │      Cập nhật ngay (Update)      │  │
│                                        │       │  └──────────────────────────────────┘  │
│                                        │       │              Để sau                    │
└────────────────────────────────────────┘       └────────────────────────────────────────┘
        [ SwiftUI / UIKit Alert ]                        [ Custom SwiftUI Card Sheet ]
```

### 2. Force Update (Mandatory) vs. Maintenance Mode

```
┌────────────────────────────────────────┐       ┌────────────────────────────────────────┐
│             Update Required            │       │            Hệ Thống Bảo Trì            │
│                   ⚠️                   │       │                   🛠️                   │
│  This version is deprecated. Please    │       │  Hệ thống đang bảo trì định kỳ để      │
│  update to continue using the service. │       │  nâng cấp server. Vui lòng quay lại    │
│                                        │       │  sau ít phút.                          │
│                                        │       │                                        │
│  ┌──────────────────────────────────┐  │       │  ┌──────────────────────────────────┐  │
│  │           Cập nhật ngay          │  │       │  │              Đã hiểu             │  │
│  └──────────────────────────────────┘  │       │  └──────────────────────────────────┘  │
└────────────────────────────────────────┘       └────────────────────────────────────────┘
         [ Non-dismissable Modal ]                       [ Server Maintenance Modal ]
```

---

## 🌟 Highlights & Architecture

- **Zero Third-Party Dependencies:** 100% Apple Native (`Foundation`, `SwiftUI`, `Combine`, `UIKit`).
- **O(N) SemVer Normalizer:** Integer vector comparison (`"1.2"` == `"1.2.0"` == `"1.2.0.0"`, `"1.10.0"` > `"1.2.0"`), safely stripping prerelease tags and build metadata.
- **Fail-Safe by Default:** Network errors, timeouts, or corrupt JSON gracefully fallback to `.none` without crashing or blocking users.
- **Decoupled Architecture:** Pure logic engine (`AppUpdateChecker.evaluate`) is fully separated from I/O fetchers and UI presentation.
- **Full Lifecycle Events & Analytics:** Emits granular events (`checkStarted`, `configFetched`, `evaluated`, `presented`, `userAction`, `checkFailed`) for Firebase, Mixpanel, and Telemetry tracking.
- **Swift 6 & Sendable Compliant:** Zero data races, `@MainActor` UI safety.

```
 ┌──────────────────────┐        ┌──────────────────────┐
 │   microCMS / JSON    │───────▶│   AppUpdateFetcher   │
 └──────────────────────┘        └──────────┬───────────┘
                                            │ async throws -> AppUpdateConfig
                                            ▼
 ┌──────────────────────┐        ┌──────────────────────┐
 │      AppVersion      │───────▶│   AppUpdateChecker   │
 └──────────────────────┘        └──────────┬───────────┘
                                            │ AppUpdateAction
                                            ▼
 ┌──────────────────────────────────────────────────────────────┐
 │                    AppUpdateAction Types                     │
 │  • .none                                                     │
 │  • .optionalUpdate(title, message, storeURL, releaseNotes)   │
 │  • .forceUpdate(title, message, storeURL, releaseNotes)      │
 │  • .maintenance(title, message)                              │
 └──────────────────────────────┬───────────────────────────────┘
                                │
          ┌─────────────────────┴─────────────────────┐
          ▼                                           ▼
┌──────────────────┐                        ┌──────────────────┐
│   SwiftUI View   │                        │   UIKit Helper   │
│  .appUpdateAlert │                        │ presentAppUpdate │
│  .appUpdateSheet │                        │   (Controllers)  │
└──────────────────┘                        └──────────────────┘
```

---

## 📦 Installation

### Swift Package Manager (SPM)

In Xcode, select **File > Add Package Dependencies...** and enter:

```
https://github.com/iletai/AppUpdateKit.git
```

Or add directly to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iletai/AppUpdateKit.git", from: "1.0.0")
]
```

---

## 🛠️ Remote Backend Configuration

`AppUpdateKit` supports both `snake_case` and `camelCase` response payloads.

### JSON Payload Schema

```json
{
  "minimum_version": "1.0.0",
  "latest_version": "2.1.0",
  "store_url": "https://apps.apple.com/app/id123456789",
  "is_maintenance": false,
  "title": "Bản cập nhật mới 2.1.0",
  "message": "Nhiều tính năng mới hấp dẫn và sửa lỗi hiệu năng.",
  "release_notes": [
    "✨ Hỗ trợ giao diện Liquid Glass & Dark Mode",
    "⚡️ Tối ưu hóa hiệu năng khởi động nhanh hơn 40%",
    "🐛 Sửa lỗi đồng bộ dữ liệu"
  ]
}
```

### microCMS Setup Schema

| Field ID | Field Name | Type | Description |
| :--- | :--- | :--- | :--- |
| `minimum_version` | Minimum Required Version | Text | Versions below this trigger mandatory Force Update (e.g. `1.0.0`) |
| `latest_version` | Latest Version | Text | Latest version available on App Store (e.g. `2.1.0`) |
| `store_url` | App Store URL | Text | Link to App Store or TestFlight |
| `is_maintenance` | Maintenance Mode | Boolean | Toggle maintenance state |
| `title` | Dialog Title | Text (Optional) | Custom title |
| `message` | Dialog Message | TextArea (Optional) | Custom description |
| `release_notes` | Release Notes | TextArea / List (Optional) | Bullet points or newline-separated notes |

---

## 🚀 Usage Guide

### 1. SwiftUI Native Alert

```swift
import SwiftUI
import AppUpdateKit

@main
struct MyApp: App {
    @State private var updateAction: AppUpdateAction = .none

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appUpdateAlert(
                    action: $updateAction,
                    configuration: AppUpdateUIConfiguration(
                        updateButtonTitle: "Cập nhật",
                        laterButtonTitle: "Để sau",
                        dismissButtonTitle: "Đã hiểu"
                    ),
                    onEvent: { event in
                        print("AppUpdate Event: \(event)")
                    }
                )
                .task {
                    let fetcher = AppUpdateFetcher.microCMS(
                        endpoint: URL(string: "https://your-service.microcms.io/api/v1/app-update")!,
                        apiKey: "YOUR_MICROCMS_API_KEY"
                    )
                    updateAction = await AppUpdateChecker.check(fetcher: fetcher)
                }
        }
    }
}
```

---

### 2. SwiftUI Custom Sheet with Release Notes

```swift
ContentView()
    .appUpdateSheet(
        action: $updateAction,
        accentColor: .indigo,
        onEvent: { event in
            // Handle Analytics
            if case .userAction(let action, let choice) = event {
                Analytics.logEvent("update_prompt_interaction", parameters: [
                    "choice": "\(choice)",
                    "action_title": action.title ?? ""
                ])
            }
        }
    )
```

---

### 3. UIKit Integration (`UIViewController`)

```swift
import UIKit
import AppUpdateKit

class MainViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForUpdates()
    }

    private func checkForUpdates() {
        Task { [weak self] in
            guard let self = self else { return }

            let fetcher = AppUpdateFetcher.json(
                url: URL(string: "https://your-domain.com/app-update.json")!
            )

            let action = await AppUpdateChecker.check(fetcher: fetcher)

            self.presentAppUpdate(
                action: action,
                configuration: AppUpdateUIConfiguration(
                    updateButtonTitle: "Cập nhật ngay",
                    laterButtonTitle: "Bỏ qua",
                    dismissButtonTitle: "Đóng"
                ),
                onEvent: { event in
                    print("[AppUpdateKit] \(event)")
                }
            )
        }
    }
}
```

---

### 4. Stateful Manager & Throttling Policy (`AppUpdateManager`)

Use `AppUpdateManager` to prevent hammering servers on every app active:

```swift
let manager = AppUpdateManager.shared

// Check once per session
await manager.check(
    policy: .oncePerSession,
    fetcher: fetcher
)

// Or check at most once every 24 hours
await manager.check(
    policy: .interval(24 * 3600),
    fetcher: fetcher
)
```

---

### 5. Unit Testing with Pure Logic Engine

You can test version evaluation deterministically without mocking network calls:

```swift
import XCTest
import AppUpdateKit

final class AppVersionPolicyTests: XCTestCase {
    func testForceUpdateTriggered() {
        let config = AppUpdateConfig(
            minimumVersion: "2.0.0",
            latestVersion: "2.5.0",
            storeURL: URL(string: "https://apps.apple.com/app/id123")!
        )

        let action = AppUpdateChecker.evaluate(
            currentVersion: AppVersion("1.9.9"),
            config: config
        )

        XCTAssertTrue(action.isRequired)
        XCTAssertTrue(action.isBlocking)
        XCTAssertEqual(action.storeURL, config.storeURL)
    }
}
```

---

## 📊 Semantic Versioning Matrix

| Current Version | Remote Minimum | Remote Latest | Evaluated Action | Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `1.0.0` | `2.0.0` | `2.5.0` | `.forceUpdate` | 🚨 User must update to continue |
| `2.0.0` | `1.5.0` | `2.1.0` | `.optionalUpdate` | 💡 Update prompt with "Later" option |
| `2.1.0` | `1.5.0` | `2.1.0` | `.none` | ✅ App is up-to-date |
| `2.1.0.0` | `1.5.0` | `2.1` | `.none` | ✅ Normalized version match |
| `any` | `any` | `any` (`isMaintenance: true`) | `.maintenance` | 🛠️ Full blocking maintenance mode |
| `1.0.0` | Network Error (404/500/Timeout) | N/A | `.none` | 🛡️ Fail-safe: app opens normally |

---

## 📋 Example Project

Check out the interactive demo in the [`Examples/`](Examples/) folder:
- **`Examples/SwiftUI/AppUpdateDemoView.swift`**: Full SwiftUI simulator.
- **`Examples/UIKit/ViewController.swift`**: UIKit implementation.
- **`Examples/microcms-schema.json`**: Ready-to-import microCMS schema.
- **`Examples/config.json`**: Sample JSON config payload.

---

## 📄 License

AppUpdateKit is released under the **MIT License**. See [LICENSE](LICENSE) for details.
