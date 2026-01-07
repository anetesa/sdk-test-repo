import Foundation
import Testing

/// Utilities for testing async/await code
enum AsyncTestUtilities {
    
    /// Wait for a condition to become true with timeout
    /// - Parameters:
    ///   - condition: Closure that returns true when condition is met
    ///   - timeout: Maximum time to wait (default: 5 seconds)
    ///   - interval: How often to check the condition (default: 0.1 seconds)
    /// - Returns: True if condition was met, false if timeout
    static func waitForCondition(
        condition: @escaping () -> Bool,
        timeout: TimeInterval = 5.0,
        interval: TimeInterval = 0.1
    ) async -> Bool {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if condition() {
                return true
            }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        
        return false
    }
    
    /// Wait for a value to be set (non-nil) with timeout
    static func waitForValue<T>(
        getValue: @escaping () -> T?,
        timeout: TimeInterval = 5.0,
        interval: TimeInterval = 0.1
    ) async -> T? {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if let value = getValue() {
                return value
            }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        
        return nil
    }
    
    /// Execute a closure and capture any thrown errors
    static func captureError<T>(
        _ closure: @escaping () async throws -> T
    ) async -> Error? {
        do {
            _ = try await closure()
            return nil
        } catch {
            return error
        }
    }
    
    /// Execute a closure and return result or error
    static func execute<T>(
        _ closure: @escaping () async throws -> T
    ) async -> Result<T, Error> {
        do {
            let value = try await closure()
            return .success(value)
        } catch {
            return .failure(error)
        }
    }
    
}

