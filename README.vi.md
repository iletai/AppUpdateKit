<p align="center">
  <img src="art/banner.svg" alt="AppUpdateKit Banner" width="100%" />
</p>

<p align="center">
  <a href="https://github.com/iletai/AppUpdateKit/actions"><img src="https://github.com/iletai/AppUpdateKit/workflows/Swift%20CI/badge.svg" alt="CI Status"></a>
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg" alt="Phiên bản Swift">
  <img src="https://img.shields.io/badge/Platforms-iOS%2014+%20%7C%20macOS%2011+%20%7C%20watchOS%207+%20%7C%20tvOS%2014+%20%7C%20Linux-blue.svg" alt="Nền tảng">
  <img src="https://img.shields.io/badge/Dependencies-0%20Zero-green.svg" alt="Không phụ thuộc">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-black.svg" alt="Giấy phép"></a>
</p>

<p align="center">
  🌐 <b>Language Selection / Chọn ngôn ngữ / 言語選択:</b><br/>
  <a href="README.md">🇬🇧 English</a> &nbsp;|&nbsp;
  <b>🇻🇳 Tiếng Việt</b> &nbsp;|&nbsp;
  <a href="README.ja.md">🇯🇵 日本語</a>
</p>

---

# AppUpdateKit

**AppUpdateKit** là thư viện Swift Package Manager (SPM) siêu nhẹ, zero-dependency, thiết kế theo triết lý **Headless-First (Không ép buộc dùng UI có sẵn)**. Hỗ trợ kiểm tra phiên bản ứng dụng, kích hoạt **Force Update (Cập nhật bắt buộc)**, **Optional Update (Cập nhật tùy chọn kèm Release Notes)**, và **Maintenance Mode (Bảo trì hệ thống)** từ xa qua **microCMS**, **Raw JSON (GitHub Raw, S3, Cloudflare Workers)**, hoặc bất kỳ API backend nào.

### 🌟 Điểm nổi bật & Triết lý thiết kế
- **Headless-First 100% (UI hoàn toàn tùy chọn):** AppUpdateKit được xây dựng như một Pure Business Logic Engine (`AppUpdateChecker`, `AppUpdateEvaluator`, `AppVersion`, `AppUpdateConfig`). Bạn **không bao giờ bị ép buộc dùng UI mặc định**. Toàn bộ raw models, metadata, version object và event stream được mở hoàn toàn để bạn tự render giao diện custom, modal, hoặc bridge qua React Native / Flutter.
- **0 Dependency bên ngoài:** Thuần Swift Standard Library (`Foundation`, `SwiftUI`, `Combine`, `UIKit`).
- **Bộ so sánh SemVer O(N):** Chuẩn hóa so sánh vector số nguyên (`"1.2"` == `"1.2.0"` == `"1.2.0.0"`, `"1.10.0"` > `"1.2.0"`), tự động loại bỏ tag prerelease và build metadata.
- **An toàn tuyệt đối (Fail-Safe):** Khi mất mạng, server timeout hoặc JSON hỏng, app tự fallback về `.none`, không làm crash hoặc block user khởi động app.
- **Vòng đời Event & Analytics chi tiết:** Bắn đầy đủ sự kiện (`checkStarted`, `configFetched`, `evaluated`, `presented`, `userAction`, `checkFailed`) cho Firebase Analytics, Mixpanel, TelemetryDeck.
- **Tương thích Swift 6 & Sendable:** An toàn tuyệt đối với `@MainActor` và Task deduplication.

---

## 📱 Minh họa Giao diện (Visual UI Preview)

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

Sử dụng logic kiểm tra thuần túy mà không đụng đến code UI:

```swift
import AppUpdateKit

let fetcher = AppUpdateFetcher.microCMS(
    endpoint: URL(string: "https://your-service.microcms.io/api/v1/app-update")!,
    apiKey: "YOUR_API_KEY"
)

// Kiểm tra trạng thái cập nhật bất đồng bộ (fail-safe)
let action: AppUpdateAction = await AppUpdateChecker.check(
    onEvent: { event in
        Analytics.logEvent("app_update_lifecycle", parameters: ["event": "\(event)"])
    },
    fetcher: fetcher
)

// Xử lý action trong View, Modal hoặc Coordinator riêng của bạn
switch action {
case .none:
    print("Ứng dụng đang ở bản mới nhất")
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

## 🎨 UI Modifiers Có Sẵn (Tùy chọn)

### 1. SwiftUI Native Alert
```swift
ContentView()
    .appUpdateAlert(
        action: $updateAction,
        configuration: AppUpdateUIConfiguration(
            updateButtonTitle: "Cập nhật ngay",
            laterButtonTitle: "Để sau",
            dismissButtonTitle: "Đồng ý"
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

### 3. Tích hợp UIKit (`UIViewController`)
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

## 📊 Bảng so sánh Semantic Versioning

| Version hiện tại | Remote Minimum | Remote Latest | Action trả về | Hành vi ứng dụng |
| :--- | :--- | :--- | :--- | :--- |
| `1.0.0` | `2.0.0` | `2.5.0` | `.forceUpdate` | 🚨 Bắt buộc cập nhật để tiếp tục |
| `2.0.0` | `1.5.0` | `2.1.0` | `.optionalUpdate` | 💡 Hiện thông báo cập nhật (có nút "Để sau") |
| `2.1.0` | `1.5.0` | `2.1.0` | `.none` | ✅ App đã ở bản mới nhất |
| `2.1.0.0` | `1.5.0` | `2.1` | `.none` | ✅ Chuẩn hóa chuỗi version trùng khớp |
| `bất kỳ` | `bất kỳ` | `bất kỳ` (`is_maintenance: true`) | `.maintenance` | 🛠️ Khóa ứng dụng, hiện màn hình bảo trì |
| `1.0.0` | Lỗi mạng (404/500/Timeout) | N/A | `.none` | 🛡️ Fail-safe: app hoạt động bình thường |

---

## 🛠️ Cấu hình API Schema microCMS

| Field ID | Tên hiển thị | Loại dữ liệu | Mô tả |
| :--- | :--- | :--- | :--- |
| `minimum_version` | Phiên bản tối thiểu | Text | Nhỏ hơn bản này sẽ kích hoạt cập nhật bắt buộc |
| `latest_version` | Phiên bản mới nhất | Text | Phiên bản mới nhất đang có trên App Store |
| `store_url` | Đường dẫn App Store | Text | Link đến App Store hoặc TestFlight |
| `is_maintenance` | Đang bảo trì | Boolean | Cờ bật/tắt chế độ bảo trì |
| `title` | Tiêu đề | Text (Tùy chọn) | Tiêu đề thông báo custom |
| `message` | Nội dung | Multi-line Text (Tùy chọn) | Mô tả chi tiết custom |
| `release_notes` | Nội dung cập nhật | Multi-line Text / Array | Danh sách các thay đổi mới |

---

## 📦 Cài đặt (SPM)

```swift
dependencies: [
    .package(url: "https://github.com/iletai/AppUpdateKit.git", from: "1.1.0")
]
```

## 📄 Giấy phép (License)

AppUpdateKit được phát hành theo **Giấy phép MIT**. Bản quyền (c) 2026 iletai.
