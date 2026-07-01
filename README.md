# MonoMockLib

Welcome to **MonoMockLib**, a monorepo containing lightweight, utility Swift packages ready to be published and integrated into iOS projects.

## Packages Included

### 1. MockLib (UserDefaults Property Wrappers)
A type-safe and modern utility that simplifies using `UserDefaults` in Swift via property wrappers.
- Supports plist-compatible types via `@UserDefault`.
- Supports custom `Codable` objects using automatic JSON serialization via `@CodableUserDefault`.
- Allows custom `UserDefaults` suite injection.

### 2. MockLibB (Declarative Validation Kit)
A declarative, type-safe validation engine optimized for input forms and specialized validation rules (specifically designed for local workflows like Thai Citizen ID modulo-11 and Thai Mobile Number check).
- Supports clean type-erased rule arrays.
- Includes built-in validations: `.notEmpty`, `.minLength`, `.maxLength`, `.email`, `.thaiMobileNumber`, `.thaiCitizenID`.

---

## SPM Integration

Since this is a monorepo, you can import specific libraries as targets by pointing to the repository path:

```swift
dependencies: [
    .package(url: "https://github.com/nker31/MonoMockLib.git", from: "1.0.0")
]
```

Then add the appropriate target to your application dependencies:
- `"MockLib"`
- `"MockLibB"`

---

## License

Both projects are open-source and licensed under the MIT License.
