# MockLibB (ValidatorKit)

A declarative, type-safe validation engine for Swift, optimized for iOS form validation and specialized domain validations (such as Thai Citizen IDs and Thai Mobile Numbers).

Ideal for mobile banking, Clean Architecture form workflows, or simple MVVM input validation.

---

## Features

- ✅ **Type-Erased Rule Architecture**: Combine multiple validation rules for a single value type cleanly.
- ✅ **Built-in Common Rules**: `NotEmpty`, `MinLength`, `MaxLength`, and `Email` check.
- ✅ **Domain-Specific Rules**: 
  - **Thai Citizen ID**: Validates the 13-digit identification check digit using the standard Modulo 11 algorithm (supporting dash/space formatting).
  - **Thai Mobile Number**: Validates 10-digit mobile numbers starting with standard prefixes (`06`, `08`, `09`).
- ✅ **Zero Dependencies**: Pure standard library implementation.

---

## Installation

### Swift Package Manager (SPM)

Add the dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/MockLibB.git", from: "1.0.0")
]
```

Or add via Xcode (**File** > **Add Package Dependencies...**).

---

## Usage

### Simple Single Validation

You can validate a value against a single rule:

```swift
import MockLibB

let email = "test@example.com"
let result = Validator.validate(email, rules: [.email])

switch result {
case .success:
    print("Valid email!")
case .failure(let error):
    print("Validation failed: \(error.localizedDescription)")
}
```

### Complex Form Validation

Combine multiple rules using simple dot syntax. Rules are executed sequentially, returning the first failing rule error:

```swift
import MockLibB

struct RegistrationForm {
    var email: String
    var mobile: String
    var citizenID: String
    
    func validate() -> Result<Void, ValidationError> {
        // Validate Email
        let emailResult = Validator.validate(email, rules: [.notEmpty, .email])
        if case .failure(let error) = emailResult { return .failure(error) }
        
        // Validate Thai Mobile
        let phoneResult = Validator.validate(mobile, rules: [.notEmpty, .thaiMobileNumber])
        if case .failure(let error) = phoneResult { return .failure(error) }
        
        // Validate Thai Citizen ID
        let citizenIDResult = Validator.validate(citizenID, rules: [.notEmpty, .thaiCitizenID])
        if case .failure(let error) = citizenIDResult { return .failure(error) }
        
        return .success(())
    }
}
```

### Checking Specific Errors

The library includes localized messages out of the box:

```swift
let invalidID = "1-2345-67890-12-3"
let result = Validator.validate(invalidID, rules: [.thaiCitizenID])

if case .failure(let error) = result {
    print(error.localizedDescription) 
    // Output: "Please enter a valid 13-digit Thai Citizen ID."
}
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
