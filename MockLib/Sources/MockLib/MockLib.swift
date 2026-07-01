import Foundation

/// A helper protocol to detect and handle optional types with nil values in property wrappers.
internal protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    internal var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
}

/// A property wrapper that simplifies accessing and modifying values in `UserDefaults`.
///
/// It supports standard plist-compatible types (e.g., `String`, `Int`, `Double`, `Bool`, `Data`, `Date`, etc.).
/// For custom `Codable` types, use `@CodableUserDefault` instead.
///
/// ### Example Usage:
/// ```swift
/// struct AppSettings {
///     @UserDefault(key: "is_dark_mode_enabled", defaultValue: false)
///     static var isDarkModeEnabled: Bool
///
///     @UserDefault(key: "user_nickname", defaultValue: nil)
///     static var userNickname: String?
/// }
/// ```
@propertyWrapper
public struct UserDefault<Value> {
    public let key: String
    public let defaultValue: Value
    public let container: UserDefaults

    /// Initializes the property wrapper with a key, a default value, and an optional custom `UserDefaults` container.
    /// - Parameters:
    ///   - key: The key associated with the value in `UserDefaults`.
    ///   - defaultValue: The default value to return if the key does not exist.
    ///   - container: The `UserDefaults` instance to use. Defaults to `.standard`.
    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }

    public var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }
}

/// A property wrapper that stores custom `Codable` objects in `UserDefaults` by serializing them to JSON.
///
/// ### Example Usage:
/// ```swift
/// struct UserProfile: Codable {
///     let name: String
///     let age: Int
/// }
///
/// struct AppSettings {
///     @CodableUserDefault(key: "user_profile", defaultValue: nil)
///     static var userProfile: UserProfile?
/// }
/// ```
@propertyWrapper
public struct CodableUserDefault<Value: Codable> {
    public let key: String
    public let defaultValue: Value
    public let container: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Initializes the property wrapper for Codable types with a key, a default value, and custom settings.
    /// - Parameters:
    ///   - key: The key associated with the value in `UserDefaults`.
    ///   - defaultValue: The default value to return if decoding fails or the key does not exist.
    ///   - container: The `UserDefaults` instance to use. Defaults to `.standard`.
    ///   - encoder: The JSONEncoder to use for serialization. Defaults to a standard `JSONEncoder`.
    ///   - decoder: The JSONDecoder to use for deserialization. Defaults to a standard `JSONDecoder`.
    public init(
        key: String,
        defaultValue: Value,
        container: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
        self.encoder = encoder
        self.decoder = decoder
    }

    public var wrappedValue: Value {
        get {
            guard let data = container.data(forKey: key) else {
                return defaultValue
            }
            do {
                return try decoder.decode(Value.self, from: data)
            } catch {
                #if DEBUG
                print("MockLib: Failed to decode object for key '\(key)': \(error)")
                #endif
                return defaultValue
            }
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                do {
                    let data = try encoder.encode(newValue)
                    container.set(data, forKey: key)
                } catch {
                    #if DEBUG
                    print("MockLib: Failed to encode object for key '\(key)': \(error)")
                    #endif
                }
            }
        }
    }
}
