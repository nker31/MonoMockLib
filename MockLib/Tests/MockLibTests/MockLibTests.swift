import XCTest
@testable import MockLib

final class MockLibTests: XCTestCase {
    
    private var testUserDefaults: UserDefaults!
    private let suiteName = "com.mocklib.tests"
    
    override func setUp() {
        super.setUp()
        // Initialize a clean suite for each test run to isolate standard defaults
        testUserDefaults = UserDefaults(suiteName: suiteName)
        testUserDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: suiteName)
        testUserDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Standard UserDefault Tests
    
    func testStandardUserDefaultWithDefaultValue() {
        struct Settings {
            @UserDefault(key: "test_key", defaultValue: 42, container: .standard)
            static var testValue: Int
        }
        
        // Ensure standard container defaults back
        XCTAssertEqual(Settings.testValue, 42)
    }
    
    func testUserDefaultSavesAndRetrievesValue() {
        struct TestContainer {
            @UserDefault(key: "username", defaultValue: "Guest", container: UserDefaults(suiteName: "com.mocklib.tests")!)
            var username: String
        }
        
        var container = TestContainer()
        XCTAssertEqual(container.username, "Guest")
        
        container.username = "Alice"
        XCTAssertEqual(container.username, "Alice")
        
        // Verify it was persisted to the suite
        let persistedValue = testUserDefaults.string(forKey: "username")
        XCTAssertEqual(persistedValue, "Alice")
    }
    
    func testUserDefaultHandlesOptionalNil() {
        struct TestContainer {
            @UserDefault(key: "optional_token", defaultValue: nil, container: UserDefaults(suiteName: "com.mocklib.tests")!)
            var token: String?
        }
        
        var container = TestContainer()
        XCTAssertNil(container.token)
        
        container.token = "some-jwt-token"
        XCTAssertEqual(container.token, "some-jwt-token")
        
        container.token = nil
        XCTAssertNil(container.token)
        XCTAssertNil(testUserDefaults.object(forKey: "optional_token"))
    }
    
    // MARK: - CodableUserDefault Tests
    
    struct User: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    func testCodableUserDefaultSavesAndRetrievesStruct() {
        struct TestContainer {
            @CodableUserDefault(key: "current_user", defaultValue: nil, container: UserDefaults(suiteName: "com.mocklib.tests")!)
            var currentUser: User?
        }
        
        var container = TestContainer()
        XCTAssertNil(container.currentUser)
        
        let user = User(id: 1, name: "Bob")
        container.currentUser = user
        
        XCTAssertEqual(container.currentUser, user)
        
        // Verify JSON data was stored in the suite
        let data = testUserDefaults.data(forKey: "current_user")
        XCTAssertNotNil(data)
        
        let decodedUser = try? JSONDecoder().decode(User.self, from: data!)
        XCTAssertEqual(decodedUser, user)
    }
    
    func testCodableUserDefaultHandlesDefaultValueOnDecodeFailure() {
        let defaultUser = User(id: 0, name: "Default")
        struct TestContainer {
            @CodableUserDefault(key: "corrupted_user", defaultValue: User(id: 0, name: "Default"), container: UserDefaults(suiteName: "com.mocklib.tests")!)
            var currentUser: User
        }
        
        // Write invalid data (not JSON) to standard defaults
        testUserDefaults.set("invalid_json_data".data(using: .utf8), forKey: "corrupted_user")
        
        let container = TestContainer()
        // It should fallback to default value on decode failure
        XCTAssertEqual(container.currentUser, defaultUser)
    }
}
