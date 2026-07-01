import XCTest
@testable import MockLibB

final class MockLibBTests: XCTestCase {
    
    func testNotEmptyRule() {
        XCTAssertEqual(Validator.validate("", rules: [.notEmpty]), .invalid(.empty))
        XCTAssertEqual(Validator.validate("   ", rules: [.notEmpty]), .invalid(.empty))
        XCTAssertEqual(Validator.validate("Hello", rules: [.notEmpty]), .valid)
    }
    
    func testMinLengthRule() {
        XCTAssertEqual(Validator.validate("abc", rules: [.minLength(5)]), .invalid(.tooShort(min: 5)))
        XCTAssertEqual(Validator.validate("abcde", rules: [.minLength(5)]), .valid)
    }
    
    func testMaxLengthRule() {
        XCTAssertEqual(Validator.validate("abcdef", rules: [.maxLength(5)]), .invalid(.tooLong(max: 5)))
        XCTAssertEqual(Validator.validate("abcde", rules: [.maxLength(5)]), .valid)
    }
    
    func testEmailRule() {
        XCTAssertEqual(Validator.validate("invalid-email", rules: [.email]), .invalid(.invalidEmail))
        XCTAssertEqual(Validator.validate("user@domain", rules: [.email]), .invalid(.invalidEmail))
        XCTAssertEqual(Validator.validate("user@domain.com", rules: [.email]), .valid)
    }
    
    func testThaiMobileNumberRule() {
        // Valid Thai mobile numbers
        XCTAssertEqual(Validator.validate("0812345678", rules: [.thaiMobileNumber]), .valid)
        XCTAssertEqual(Validator.validate("09-8765-4321", rules: [.thaiMobileNumber]), .valid)
        XCTAssertEqual(Validator.validate("06 1111 2222", rules: [.thaiMobileNumber]), .valid)
        
        // Invalid Thai mobile numbers
        XCTAssertEqual(Validator.validate("1812345678", rules: [.thaiMobileNumber]), .invalid(.invalidThaiMobileNumber)) // doesn't start with 0
        XCTAssertEqual(Validator.validate("021234567", rules: [.thaiMobileNumber]), .invalid(.invalidThaiMobileNumber))  // too short / landline prefix
        XCTAssertEqual(Validator.validate("08123456789", rules: [.thaiMobileNumber]), .invalid(.invalidThaiMobileNumber)) // too long
    }
    
    func testThaiCitizenIDRule() {
        // A valid Thai Citizen ID: 1103702411981
        let validID = "1103702411981"
        let validFormattedID = "1-1037-02411-98-1"
        let invalidID = "1103702411982" // incorrect check digit
        
        XCTAssertEqual(Validator.validate(validID, rules: [.thaiCitizenID]), .valid)
        XCTAssertEqual(Validator.validate(validFormattedID, rules: [.thaiCitizenID]), .valid)
        XCTAssertEqual(Validator.validate(invalidID, rules: [.thaiCitizenID]), .invalid(.invalidThaiCitizenID))
        XCTAssertEqual(Validator.validate("12345", rules: [.thaiCitizenID]), .invalid(.invalidThaiCitizenID)) // Too short
    }
    
    func testValidatorMultipleRules() {
        let rules: [AnyValidationRule<String>] = [
            .notEmpty,
            .minLength(5),
            .email
        ]
        
        XCTAssertEqual(Validator.validate("", rules: rules), .invalid(.empty))
        XCTAssertEqual(Validator.validate("abc", rules: rules), .invalid(.tooShort(min: 5)))
        XCTAssertEqual(Validator.validate("abcde", rules: rules), .invalid(.invalidEmail))
        XCTAssertEqual(Validator.validate("user@domain.com", rules: rules), .valid)
    }
}
