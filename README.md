<p align="center">
  <img src="art/banner.svg" alt="AppUpdateKit Banner" width="100%" />
</p>

<p align="center">
  <a href="https://github.com/iletai/AppUpdateKit/actions"><img src="https://github.com/iletai/AppUpdateKit/workflows/Swift%20CI/badge.svg" alt="CI Status"></a>
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Platforms-iOS%2014+%20%7C%20macOS%2011+%20%7C%20watchOS%207+%20%7C%20tvOS%2014+%20%7C%20Linux-blue.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/Dependencies-0%20Zero-green.svg" alt="Zero Dependencies">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-black.svg" alt="License"></a>
</p>

<p align="center">
  <b>English</b> | <a href="#-tiếng-việt">Tiếng Việt</a> | <a href="#-日本語">日本語</a>
</p>

---

# 🇬🇧 English

**AppUpdateKit** is an ultra-lightweight, zero-dependency, **headless-first** Swift Package for evaluating app versions, enforcing **Force Updates**, presenting **Optional Updates** (with release notes), and activating **Maintenance Mode** remotely via **microCMS**, **Raw JSON (GitHub Raw, S3, Cloudflare Workers)**, or any backend endpoint.

### 🛡️ Core Values & Design Principles
- **100% Headless-First (UI is strictly optional):** AppUpdateKit is built as a pure business logic engine (`AppUpdateChecker`, `AppUpdateEvaluator`, `AppVersion`, `AppUpdateConfig`). You are **never forced to use our UI**. All raw models, metadata, version objects, and event streams are exposed so you can render your own custom dialogs, sheets, or bridges (React Native, Flutter).
- **Zero Third-Party Dependencies:** Pure Swift Standard Library (`Foundation`, `SwiftUI`, `Combine`, `UIKit`).
- **O(N) SemVer Normalizer:** Vector integer comparator (`"1.2"` == `"1.2.0"` == `"1.2.0.0"`, `"1.10.0"` > `"1.2.0"`), stripping prerelease tags and build metadata.
- **Fail-Safe by Default:** Network errors, timeouts, or corrupt JSON gracefully fallback to `.none` without crashing or blocking users.
- **Full Lifecycle Events & Analytics:** Emits granular events (`checkStarted`, `configFetched`, `evaluated`, `presented`, `userAction`, `checkFailed`) for Firebase, Mixpanel, and custom logging.
- **Swift 6 & Sendable Compliant:** Fully concurrency-safe with `@MainActor` safety and Task deduplication.

---

## 📱 Visual UI Preview

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

---

## 🚀 Quick Start (100% Headless / Custom UI)

Use pure evaluation logic without touching any UI code:

```swift
import AppUpdateKit

let fetcher = AppUpdateFetcher.microCMS(
    endpoint: URL(string: "https://your-service.microcms.io/api/v1/app-update")!,
    apiKey: "YOUR_API_KEY"
)

// Check update status asynchronously (fail-safe)
let action: AppUpdateAction = await AppUpdateChecker.check(
    onEvent: { event in
        Analytics.logEvent("app_update_lifecycle", parameters: ["event": "\(event)"])
    },
    fetcher: fetcher
)

// Handle action in your own custom View, Modal, or Coordinator
switch action {
case .none:
    print("App is up-to-date")
case .optionalUpdate(let title, let message, let storeURL, let version, let releaseNotes, let metadata):
    MyCustomDialogPresenter.showOptionalUpdate(title: title, version: version?.description, url: storeURL)
case .forceUpdate(let title, let message, let storeURL, let version, let releaseNotes, let metadata):
    MyCustomDialogPresenter.showBlockingUpdate(title: title, url: storeURL)
case .maintenance(let title, let message, let metadata):
    MyCustomDialogPresenter.showMaintenanceScreen(message: message)
case .custom(let id, let title, let message, let storeURL, _, _, _):
    MyCustomDialogPresenter.handleCustomAction(id: id)
}
```

---

## 🎨 Optional Pre-built UI Modifiers

### 1. SwiftUI Native Alert
```swift
ContentView()
    .appUpdateAlert(
        action: $updateAction,
        configuration: AppUpdateUIConfiguration(
            updateButtonTitle: "Update Now",
            laterButtonTitle: "Later",
            dismissButtonTitle: "OK"
        ),
        onEvent: { event in
            print("[AppUpdateKit] Event: \(event)")
        }
    )
```

### 2. SwiftUI Custom Card Sheet
```swift
ContentView()
    .appUpdateSheet(
        action: $updateAction,
        accentColor: .indigo,
        onEvent: { event in
            if case .userAction(let action, let choice) = event {
                print("User tapped \(choice) for \(action.title ?? "")")
            }
        }
    )
```

### 3. UIKit Integration (`UIViewController`)
```swift
class ViewController: UIViewController {
    func checkVersion() {
        Task { [weak self] in
            let action = await AppUpdateChecker.check(fetcher: fetcher)
            self?.presentAppUpdate(action: action)
        }
    }
}
```

---

# 🇻🇳 Tiếng Việt

**AppUpdateKit** là thư viện Swift Package Manager (SPM) siêu nhẹ, zero-dependency, thiết kế theo triết lý **Headless-First (Không ép buộc dùng UI có sẵn)**. Hỗ trợ kiểm tra phiên bản ứng dụng, kích hoạt **Force Update (Cập nhật bắt buộc)**, **Optional Update (Cập nhật tùy chọn kèm Release Notes)**, và **Maintenance Mode (Bảo trì hệ thống)** từ xa qua **microCMS**, **Raw JSON**, hoặc bất kỳ API backend nào.

### 🌟 Điểm nổi bật
1. **Headless-First 100%:** Tách biệt hoàn toàn Pure Logic Engine (`AppUpdateChecker`) khỏi tầng UI. Developer toàn quyền lấy raw action, version, metadata để tự build UI hoặc chuyển tiếp qua Flutter / React Native Bridge.
2. **0 Dependency bên ngoài:** Thuần Swift Standard Library (`Foundation`, `SwiftUI`, `Combine`, `UIKit`).
3. **Bộ so sánh SemVer O(N):** Chuẩn hóa số nguyên (`"1.2"` == `"1.2.0"` == `"1.2.0.0"`), tự động loại bỏ tag prerelease/build metadata (`1.0.0-beta.1` -> `1.0.0`).
4. **An toàn tuyệt đối (Fail-Safe):** Khi mất mạng, server timeout hoặc JSON hỏng, app tự fallback về `.none`, không làm crash hoặc block user khởi động app.
5. **Vòng đời Event & Analytics chi tiết:** Bắn đầy đủ sự kiện (`checkStarted`, `configFetched`, `evaluated`, `presented`, `userAction`, `checkFailed`) cho Firebase Analytics, Mixpanel, TelemetryDeck.

### 📊 Bảng so sánh Semantic Versioning

| Version hiện tại | Remote Minimum | Remote Latest | Action trả về | Hành vi ứng dụng |
| :--- | :--- | :--- | :--- | :--- |
| `1.0.0` | `2.0.0` | `2.5.0` | `.forceUpdate` | 🚨 Bắt buộc cập nhật để tiếp tục |
| `2.0.0` | `1.5.0` | `2.1.0` | `.optionalUpdate` | 💡 Hiện thông báo cập nhật (có nút "Để sau") |
| `2.1.0` | `1.5.0` | `2.1.0` | `.none` | ✅ App đã ở bản mới nhất |
| `2.1.0.0` | `1.5.0` | `2.1` | `.none` | ✅ Chuẩn hóa chuỗi version trùng khớp |
| `bất kỳ` | `bất kỳ` | `bất kỳ` (`is_maintenance: true`) | `.maintenance` | 🛠️ Khóa ứng dụng, hiện màn hình bảo trì |
| `1.0.0` | Lỗi mạng (404/500/Timeout) | N/A | `.none` | 🛡️ Fail-safe: app hoạt động bình thường |

---

# 🇯🇵 日本語

**AppUpdateKit** は、完全な **Headless-First** 設計を採用した超軽量・依存関係ゼロ（Zero Dependency）の Swift Package です。**microCMS** や **Raw JSON (GitHub Raw, S3, Cloudflare Workers)** などを介して、アプリの強制アップデート（Force Update）、任意アップデート（Optional Update・更新履歴付き）、およびメンテナンスモード（Maintenance Mode）をリモートで制御します。

### 🌟 主な特徴
1. **完全な Headless 設計（UI の強制なし）:** 純粋なビジネスロジックエンジンを提供し、開発者は独自のカスタム UI、モーダル、または Flutter / React Native ブリッジを自由に構築できます。
2. **外部依存性ゼロ:** Apple 標準フレームワーク（`Foundation`, `SwiftUI`, `Combine`, `UIKit`）のみで動作。
3. **O(N) SemVer 比較エンジン:** バージョン文字列の正規化（`"1.2"` == `"1.2.0"` == `"1.2.0.0"`）およびプレリリースタグ除去に対応。
4. **フェイルセーフ設計:** ネットワークエラー、タイムアウト、または不正な JSON が発生した場合でも、クラッシュせずに `.none` へ安全にフォールバック。
5. **詳細なイベント＆アナリティクス対応:** `checkStarted`, `configFetched`, `evaluated`, `presented`, `userAction`, `checkFailed` を出力し、Firebase や Mixpanel と連携可能。

### 🛠️ microCMS API スキーマ設定

| フィールド ID | 表示名 | 種類 | 説明 |
| :--- | :--- | :--- | :--- |
| `minimum_version` | 最低必須バージョン | テキスト | これ未満のバージョンで強制アップデートを発火 |
| `latest_version` | 最新バージョン | テキスト | App Store で公開中の最新バージョン |
| `store_url` | ストア URL | テキスト | App Store または TestFlight のリンク |
| `is_maintenance` | メンテナンス中 | 真偽値 | メンテナンスモードの切り替えフラグ |
| `title` | ダイアログタイトル | テキスト (任意) | カスタムタイトル |
| `message` | ダイアログ本文 | 複数行テキスト (任意) | カスタム説明文 |
| `release_notes` | 更新内容 | 複数行テキスト / リスト | 箇条書きのリリースノート |

---

## 📦 Installation (SPM)

```swift
dependencies: [
    .package(url: "https://github.com/iletai/AppUpdateKit.git", from: "1.1.0")
]
```

## 📄 License

AppUpdateKit is released under the **MIT License**. Copyright (c) 2026 iletai.
