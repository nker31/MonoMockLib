# MockLib

A lightweight, type-safe Swift library that simplifies using `UserDefaults` via modern Swift property wrappers.

`MockLib` provides two main property wrappers:
1. `@UserDefault` - for standard, plist-compatible types (`String`, `Int`, `Double`, `Bool`, `Data`, `Date`, etc.).
2. `@CodableUserDefault` - for custom `Codable` objects (automatically serialized/deserialized to JSON `Data` under the hood).

---

## Features

- ✅ **Type-safe Access**: No more manual type casting (`as? String`) when retrieving values.
- ✅ **Optional & Default Values**: Easily specify dynamic or static default values.
- ✅ **Automatic JSON Serialization**: Safely persist custom `Codable` structs/classes to `UserDefaults`.
- ✅ **Suite Isolation**: Custom `UserDefaults` containers (suites) are fully supported.
- ✅ **Zero Dependencies**: Lightweight and built purely using standard Foundation APIs.

---

## Installation

### Swift Package Manager (SPM)

To add `MockLib` to your project, add the dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/MockLib.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to **File** > **Add Package Dependencies...**
2. Enter the repository URL.
3. Choose the version rules you'd like to apply.

---

## Usage

### 1. Standard Property Wrapper (`@UserDefault`)

Use `@UserDefault` to store standard plist-compatible types (e.g., primitives, arrays, dictionaries, data, dates).

```swift
import MockLib

struct AppSettings {
    // 1. Storage with default value (non-optional)
    @UserDefault(key: "is_dark_mode", defaultValue: false)
    static var isDarkMode: Bool

    // 2. Storage with optional value defaulting to nil
    @UserDefault(key: "auth_token", defaultValue: nil)
    static var authToken: String?
}

// Writing value
AppSettings.isDarkMode = true
AppSettings.authToken = "jwt-token-123"

// Reading value
print(AppSettings.isDarkMode) // true

// Removing/Resetting value (for optionals)
AppSettings.authToken = nil // Key gets removed from UserDefaults
```

### 2. Custom Object Storage (`@CodableUserDefault`)

Use `@CodableUserDefault` to easily store custom Swift `Codable` structures or classes.

```swift
import MockLib

struct UserProfile: Codable {
    let name: String
    let email: String
    let themePreference: String
}

struct AppState {
    @CodableUserDefault(key: "current_user_profile", defaultValue: nil)
    static var profile: UserProfile?
}

// Create and save
let profile = UserProfile(name: "Nathat Kuan", email: "nathat@example.com", themePreference: "dark")
AppState.profile = profile // Automatically encoded to JSON Data

// Read
if let user = AppState.profile {
    print("Welcome, \(user.name)!")
}
```

### 3. Custom UserDefaults Container (Suites)

By default, wrappers use `UserDefaults.standard`. You can isolate your storage by providing a custom suite:

```swift
extension UserDefaults {
    static let sharedSuite = UserDefaults(suiteName: "group.com.example.app")!
}

struct SharedSettings {
    @UserDefault(key: "app_group_data", defaultValue: "default", container: .sharedSuite)
    static var sharedData: String
}
```

---

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Xcode 15.0+
- Swift 5.9+

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
