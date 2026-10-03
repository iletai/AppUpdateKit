# AppUpdateKit

Lightweight, fail-safe Swift Package for handling app update policies, force updates, optional updates, and maintenance modes across iOS, macOS, watchOS, and tvOS.

## Features

- **Semantic Version Normalization**: O(N) integer component comparison (`"1.2"` == `"1.2.0" == "1.2.0.0"`, `"1.10.0" > "1.2.0"`), stripping prerelease and build metadata.
- **Fail-Safe by Design**: Unhandled network errors or decoding failures default safely to `.none` without crashing or blocking users.
- **Multi-Format JSON Support**: Handles both `camelCase` and `snake_case` response schemas seamlessly.
- **Plug-and-Play Remote Providers**: Built-in fetchers for microCMS and generic JSON endpoints.
- **SwiftUI Native**: Pre-built `.appUpdateAlert(action:onDismiss:)` View Modifier with cross-platform URL opening.
- **Zero Dependencies**: Pure Swift standard library and Foundation.

## Requirements

- iOS 14.0+ / macOS 11.0+ / watchOS 7.0+ / tvOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iletai/AppUpdateKit.git", from: "1.0.0")
]
```

Or add via Xcode: **File > Add Package Dependencies...** and enter repository URL.

---

## Architecture Overview

```
 ┌──────────────────────┐        ┌──────────────────────┐
 │   microCMS / JSON    │───────▶│   AppUpdateFetcher   │
 └──────────────────────┘        └──────────┬───────────┘
                                            │ async () throws -> AppUpdateConfig
                                            ▼
 ┌──────────────────────┐        ┌──────────────────────┐
 │      AppVersion      │───────▶│   AppUpdateChecker   │
 └──────────────────────┘        └──────────┬───────────┘
                                            │
                                            ▼
                                 ┌──────────────────────┐
                                 │   AppUpdateAction    │
                                 │ (.none / .optional / │
                                 │  .force / .maint)    │
                                 └──────────┬───────────┘
                                            │
                                            ▼
                                 ┌──────────────────────┐
                                 │ SwiftUI Alert (.UI)  │
                                 └──────────────────────┘
```

---

## Remote Schema Example (microCMS / JSON)

You can use either `snake_case` or `camelCase` in your API response:

```json
{
  "minimum_version": "1.2.0",
  "latest_version": "2.0.0",
  "store_url": "https://apps.apple.com/app/id123456789",
  "is_maintenance": false,
  "title": "Update Available",
  "message": "A new version with bug fixes and improvements is available."
}
```

### microCMS API Schema Setup
- `minimum_version` (Text / String)
- `latest_version` (Text / String)
- `store_url` (Text / URL)
- `is_maintenance` (Boolean)
- `title` (Text / Optional)
- `message` (TextArea / Optional)

---

## Quick Start & Usage

### 1. Fetch and Evaluate

```swift
import AppUpdateKit

// Using microCMS Fetcher
let microCMSFetcher = AppUpdateFetcher.microCMS(
    endpoint: URL(string: "https://your-service.microcms.io/api/v1/app-config")!,
    apiKey: "YOUR_MICROCMS_API_KEY"
)

// Check update status asynchronously (fail-safe)
let action = await AppUpdateChecker.check(fetcher: microCMSFetcher)
```

### 2. Pure Logic Evaluation (Unit Tests / Custom Config)

```swift
let config = AppUpdateConfig(
    minimumVersion: "2.0.0",
    latestVersion: "2.1.0",
    storeURL: URL(string: "https://apps.apple.com/app/id123456789"),
    isMaintenance: false
)

let action = AppUpdateChecker.evaluate(
    currentVersion: AppVersion("1.9.0"),
    config: config
)
// Result: .forceUpdate(...)
```

### 3. SwiftUI Integration

```swift
import SwiftUI
import AppUpdateKit

@main
struct MyApp: App {
    @State private var updateAction: AppUpdateAction = .none

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appUpdateAlert(action: $updateAction)
                .task {
                    let fetcher = AppUpdateFetcher.microCMS(
                        endpoint: URL(string: "https://your-service.microcms.io/api/v1/app-config")!,
                        apiKey: "YOUR_API_KEY"
                    )
                    updateAction = await AppUpdateChecker.check(fetcher: fetcher)
                }
        }
    }
}
```

---

## Testing

Run unit tests via command line:

```bash
swift test
```

## License

MIT License. Copyright (c) 2026 iletai.
