import Foundation

/// Defines common validation errors with localized descriptions.
public enum ValidationError: Error, Equatable, LocalizedError {
    case empty
    case tooShort(min: Int)
    case tooLong(max: Int)
    case invalidEmail
    case invalidThaiCitizenID
    case invalidThaiMobileNumber
    case custom(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .empty:
            return "This field cannot be empty."
        case .tooShort(let min):
            return "Minimum length is \(min) characters."
        case .tooLong(let max):
            return "Maximum length is \(max) characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidThaiCitizenID:
            return "Please enter a valid 13-digit Thai Citizen ID."
        case .invalidThaiMobileNumber:
            return "Please enter a valid 10-digit Thai mobile number."
        case .custom(let message):
            return message
        }
    }
}

/// The result of a validation.
public enum ValidationResult: Equatable {
    case valid
    case invalid(ValidationError)
}

/// A protocol that all validation rules must adopt.
public protocol ValidationRule {
    associatedtype Value
    func validate(_ value: Value) -> ValidationResult
}

/// A type-erased validation rule wrapper to support heterogeneous rule arrays.
public struct AnyValidationRule<Value>: ValidationRule {
    private let _validate: (Value) -> ValidationResult
    
    public init<Rule: ValidationRule>(_ rule: Rule) where Rule.Value == Value {
        self._validate = rule.validate
    }
    
    public func validate(_ value: Value) -> ValidationResult {
        _validate(value)
    }
}

// MARK: - Built-in Validation Rules

public struct NotEmptyRule: ValidationRule {
    public init() {}
    public func validate(_ value: String) -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .invalid(.empty) : .valid
    }
}

public struct MinLengthRule: ValidationRule {
    public let minLength: Int
    public init(minLength: Int) {
        self.minLength = minLength
    }
    public func validate(_ value: String) -> ValidationResult {
        value.count < minLength ? .invalid(.tooShort(min: minLength)) : .valid
    }
}

public struct MaxLengthRule: ValidationRule {
    public let maxLength: Int
    public init(maxLength: Int) {
        self.maxLength = maxLength
    }
    public func validate(_ value: String) -> ValidationResult {
        value.count > maxLength ? .invalid(.tooLong(max: maxLength)) : .valid
    }
}

public struct EmailRule: ValidationRule {
    public init() {}
    public func validate(_ value: String) -> ValidationResult {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: value) ? .valid : .invalid(.invalidEmail)
    }
}

public struct ThaiMobileNumberRule: ValidationRule {
    public init() {}
    public func validate(_ value: String) -> ValidationResult {
        let cleanValue = value.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        let phoneRegEx = "^0[689]\\d{8}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: cleanValue) ? .valid : .invalid(.invalidThaiMobileNumber)
    }
}

public struct ThaiCitizenIDRule: ValidationRule {
    public init() {}
    public func validate(_ value: String) -> ValidationResult {
        let cleanValue = value.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        guard cleanValue.count == 13, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cleanValue)) else {
            return .invalid(.invalidThaiCitizenID)
        }
        
        let digits = cleanValue.compactMap { Int(String($0)) }
        guard digits.count == 13 else {
            return .invalid(.invalidThaiCitizenID)
        }
        
        var sum = 0
        for i in 0..<12 {
            sum += digits[i] * (13 - i)
        }
        
        let remainder = sum % 11
        let checkDigit = (11 - remainder) % 10
        
        return digits[12] == checkDigit ? .valid : .invalid(.invalidThaiCitizenID)
    }
}

// MARK: - DSL Syntax Extensions

extension AnyValidationRule where Value == String {
    public static var notEmpty: AnyValidationRule<String> { AnyValidationRule(NotEmptyRule()) }
    
    public static func minLength(_ length: Int) -> AnyValidationRule<String> {
        AnyValidationRule(MinLengthRule(minLength: length))
    }
    
    public static func maxLength(_ length: Int) -> AnyValidationRule<String> {
        AnyValidationRule(MaxLengthRule(maxLength: length))
    }
    
    public static var email: AnyValidationRule<String> { AnyValidationRule(EmailRule()) }
    
    public static var thaiMobileNumber: AnyValidationRule<String> { AnyValidationRule(ThaiMobileNumberRule()) }
    
    public static var thaiCitizenID: AnyValidationRule<String> { AnyValidationRule(ThaiCitizenIDRule()) }
}

// MARK: - Validator Entrypoint

public struct Validator {
    /// Validates an input value against an array of rule validations.
    /// - Parameters:
    ///   - value: The value to validate.
    ///   - rules: An array of rules for this value type.
    /// - Returns: A `ValidationResult`.
    public static func validate<Value>(_ value: Value, rules: [AnyValidationRule<Value>]) -> ValidationResult {
        for rule in rules {
            if case .invalid(let error) = rule.validate(value) {
                return .invalid(error)
            }
        }
        return .valid
    }
}
