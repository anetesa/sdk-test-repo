import Foundation
import os.log

/// Logging levels for AriseMobileSdk
public enum LogLevel: Int, CaseIterable {
    case none = 0
    case error = 1
    case warning = 2
    case info = 3
    case debug = 4
    case verbose = 5
    
    public var description: String {
        switch self {
        case .none: return "NONE"
        case .error: return "ERROR"
        case .warning: return "WARNING"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        case .verbose: return "VERBOSE"
        }
    }
}

/// Logger for AriseMobileSdk
/// Thread-safe logger using os.log which is safe for concurrent access
public final class AriseLogger: @unchecked Sendable {
    public static let shared = AriseLogger()
    
    private var logLevel: LogLevel = .info
    private let logger = Logger(subsystem: "com.arise.mobile.sdk", category: "AriseMobileSdk")
    
    private init() {}
    
    /// Set the logging level
    /// - Parameter level: The minimum log level to output
    public func setLogLevel(_ level: LogLevel) {
        logLevel = level
    }
    
    /// Get current logging level
    /// - Returns: Current log level
    public func getLogLevel() -> LogLevel {
        return logLevel
    }
    
    /// Log an error message
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    /// Log a warning message
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    /// Log an info message
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    /// Log a debug message
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    /// Log a verbose message
    public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, message: message, file: file, function: function, line: line)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard level.rawValue <= logLevel.rawValue else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(level.description)] \(fileName):\(line) \(function) - \(message)"
        
        switch level {
        case .error:
            logger.error("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .debug:
            logger.debug("\(logMessage)")
        case .verbose:
            logger.debug("\(logMessage)")
        case .none:
            break
        }
    }
}
