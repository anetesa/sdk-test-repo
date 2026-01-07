import Foundation
import Testing

/// Extensions for XCTest compatibility with Swift Testing framework
/// These utilities help bridge between XCTest and Swift Testing patterns

extension Test {
    /// Assert that a condition is true
    static func assertTrue(
        _ condition: Bool,
        _ message: String = "Condition should be true"
    ) {
        #expect(condition)
    }
    
    /// Assert that a condition is false
    static func assertFalse(
        _ condition: Bool,
        _ message: String = "Condition should be false"
    ) {
        #expect(!condition)
    }
    
    /// Assert that two values are equal
    static func assertEqual<T: Equatable>(
        _ actual: T,
        _ expected: T,
        _ message: String? = nil
    ) {
        #expect(actual == expected)
    }
    
    /// Assert that a value is nil
    static func assertNil<T>(
        _ value: T?,
        _ message: String = "Value should be nil"
    ) {
        #expect(value == nil)
    }
    
    /// Assert that a value is not nil
    static func assertNotNil<T>(
        _ value: T?,
        _ message: String = "Value should not be nil"
    ) {
        #expect(value != nil)
    }
    
    /// Assert that an error is thrown
    static func assertThrowsError<T>(
        _ expression: @escaping () async throws -> T,
        _ message: String = "Expression should throw an error"
    ) async {
        do {
            _ = try await expression()
            Issue.record("Expected error to be thrown: \(message)")
        } catch {
            // Expected - error was thrown
        }
    }
}

