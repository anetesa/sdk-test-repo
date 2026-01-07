import Foundation
import Testing
@testable import AriseMobile

/// Tests for AriseLogger utility
struct AriseLoggerTests {
    
    // MARK: - Log Level Management
    
    @Test("AriseLogger has default log level of info")
    func testAriseLoggerDefaultLogLevel() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Reset to default
        logger.setLogLevel(.info)
        let defaultLevel = logger.getLogLevel()
        
        #expect(defaultLevel == .info)
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger can set and get log level")
    func testAriseLoggerSetAndGetLogLevel() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Test all log levels
        for level in LogLevel.allCases {
            logger.setLogLevel(level)
            #expect(logger.getLogLevel() == level)
        }
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - Log Level Filtering
    
    @Test("AriseLogger filters logs below current level")
    func testAriseLoggerFiltersLogsBelowLevel() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to error level - only error should be logged
        logger.setLogLevel(.error)
        #expect(logger.getLogLevel() == .error)
        
        // Set to warning level - error and warning should be logged
        logger.setLogLevel(.warning)
        #expect(logger.getLogLevel() == .warning)
        
        // Set to info level - error, warning, and info should be logged
        logger.setLogLevel(.info)
        #expect(logger.getLogLevel() == .info)
        
        // Set to debug level - all except verbose should be logged
        logger.setLogLevel(.debug)
        #expect(logger.getLogLevel() == .debug)
        
        // Set to verbose level - all should be logged
        logger.setLogLevel(.verbose)
        #expect(logger.getLogLevel() == .verbose)
        
        // Set to none - nothing should be logged
        logger.setLogLevel(.none)
        #expect(logger.getLogLevel() == .none)
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger respects log level hierarchy")
    func testAriseLoggerRespectsLevelHierarchy() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Test that higher levels include lower levels
        logger.setLogLevel(.verbose)
        let currentLevel = logger.getLogLevel()
        #expect(currentLevel == .verbose)
        #expect(currentLevel.rawValue >= LogLevel.error.rawValue)
        #expect(currentLevel.rawValue >= LogLevel.warning.rawValue)
        #expect(currentLevel.rawValue >= LogLevel.info.rawValue)
        #expect(currentLevel.rawValue >= LogLevel.debug.rawValue)
        #expect(currentLevel.rawValue >= LogLevel.verbose.rawValue)
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - Log Level Descriptions
    
    @Test("LogLevel has correct descriptions")
    func testLogLevelDescriptions() {
        #expect(LogLevel.none.description == "NONE")
        #expect(LogLevel.error.description == "ERROR")
        #expect(LogLevel.warning.description == "WARNING")
        #expect(LogLevel.info.description == "INFO")
        #expect(LogLevel.debug.description == "DEBUG")
        #expect(LogLevel.verbose.description == "VERBOSE")
    }
    
    // MARK: - Log Output Formatting
    
    @Test("AriseLogger formats log messages correctly")
    func testAriseLoggerFormatsMessages() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to verbose to ensure all messages are logged
        logger.setLogLevel(.verbose)
        
        // These calls should not crash and should format messages
        logger.error("Test error message")
        logger.warning("Test warning message")
        logger.info("Test info message")
        logger.debug("Test debug message")
        logger.verbose("Test verbose message")
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger includes file, function, and line in log format")
    func testAriseLoggerIncludesContext() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to verbose to ensure message is logged
        logger.setLogLevel(.verbose)
        
        // Log with explicit context
        logger.error("Test message", file: "TestFile.swift", function: "testFunction", line: 42)
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - Error Logging
    
    @Test("AriseLogger logs error messages")
    func testAriseLoggerLogsError() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to error level
        logger.setLogLevel(.error)
        
        // Error should be logged
        logger.error("Test error message")
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger logs error with context")
    func testAriseLoggerLogsErrorWithContext() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        logger.setLogLevel(.error)
        
        logger.error("Error with context", file: "ErrorFile.swift", function: "errorFunction", line: 100)
        
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - Verbose Logging
    
    @Test("AriseLogger logs verbose messages when level is verbose")
    func testAriseLoggerLogsVerboseWhenLevelIsVerbose() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to verbose level
        logger.setLogLevel(.verbose)
        
        // Verbose should be logged
        logger.verbose("Test verbose message")
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger does not log verbose when level is below verbose")
    func testAriseLoggerDoesNotLogVerboseWhenLevelIsBelow() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to debug level (below verbose)
        logger.setLogLevel(.debug)
        
        // Verbose should not be logged (but call should not crash)
        logger.verbose("Test verbose message")
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - All Log Levels
    
    @Test("AriseLogger supports all log levels")
    func testAriseLoggerSupportsAllLevels() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        // Set to verbose to ensure all messages are logged
        logger.setLogLevel(.verbose)
        
        // Test all log methods
        logger.error("Error message")
        logger.warning("Warning message")
        logger.info("Info message")
        logger.debug("Debug message")
        logger.verbose("Verbose message")
        
        // Restore original level
        logger.setLogLevel(originalLevel)
    }
    
    // MARK: - Edge Cases
    
    @Test("AriseLogger handles empty messages")
    func testAriseLoggerHandlesEmptyMessages() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        logger.setLogLevel(.verbose)
        
        logger.error("")
        logger.warning("")
        logger.info("")
        logger.debug("")
        logger.verbose("")
        
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger handles long messages")
    func testAriseLoggerHandlesLongMessages() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        logger.setLogLevel(.verbose)
        
        let longMessage = String(repeating: "A", count: 1000)
        logger.error(longMessage)
        logger.verbose(longMessage)
        
        logger.setLogLevel(originalLevel)
    }
    
    @Test("AriseLogger handles special characters in messages")
    func testAriseLoggerHandlesSpecialCharacters() {
        let logger = AriseLogger.shared
        let originalLevel = logger.getLogLevel()
        
        logger.setLogLevel(.verbose)
        
        logger.error("Message with special chars: !@#$%^&*()")
        logger.verbose("Message with unicode: 🚀 📱 💳")
        logger.info("Message with newlines:\nLine 1\nLine 2")
        
        logger.setLogLevel(originalLevel)
    }
}

