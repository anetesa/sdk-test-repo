import Foundation

/// Utility for handling and logging decoding errors
/// Extracts DecodingError from various error types and logs detailed information
internal struct DecodingErrorHandler {
    private let logger: AriseLogger
    
    init(logger: AriseLogger = AriseLogger.shared) {
        self.logger = logger
    }
    
    /// Handle error by extracting DecodingError and logging details
    /// Re-throws the original error after logging
    ///
    /// - Parameter error: Error to handle
    /// - Throws: The original error (re-thrown after logging)
    func handleError(_ error: Error) throws {
        // Try to extract DecodingError from various error types
        if let decodingError = extractDecodingError(from: error) {
            logDecodingErrorDetails(decodingError)
        } else {
            // If we couldn't find DecodingError, log all available error information
            logger.error("⚠️ Could not extract DecodingError, logging full error structure:")
            logFullErrorStructure(error, depth: 0, maxDepth: 5)
        }
        
        // Re-throw the original error
        throw error
    }
    
    /// Extract DecodingError from various error types (direct, NSError, ClientError)
    private func extractDecodingError(from error: Error) -> DecodingError? {
        // Direct DecodingError
        if let decodingError = error as? DecodingError {
            return decodingError
        }
        
        // Try to extract from NSError userInfo
        if let nsError = error as NSError? {
            // Check all userInfo keys for underlying errors
            for (key, value) in nsError.userInfo {
                if key == NSUnderlyingErrorKey || key == "underlyingError" || key.description.contains("underlying") {
                    if let underlying = value as? Error {
                        if let decodingError = extractDecodingError(from: underlying) {
                            return decodingError
                        }
                    }
                }
            }
            
            // Also check for "cause" key (used by ClientError)
            if let cause = nsError.userInfo["cause"] as? Error {
                if let decodingError = extractDecodingError(from: cause) {
                    return decodingError
                }
            }
        }
        
        // Try to extract using reflection for ClientError (OpenAPIRuntime)
        // ClientError might have a "cause" property
        let mirror = Mirror(reflecting: error)
        for child in mirror.children {
            if let underlyingError = child.value as? Error {
                if let decodingError = extractDecodingError(from: underlyingError) {
                    return decodingError
                }
            }
        }
        
        return nil
    }
    
    /// Log full error structure recursively
    private func logFullErrorStructure(_ error: Error, depth: Int, maxDepth: Int) {
        guard depth < maxDepth else {
            logger.error("  [Max depth reached]")
            return
        }
        
        let indent = String(repeating: "  ", count: depth)
        logger.error("\(indent)Error type: \(type(of: error))")
        logger.error("\(indent)Error description: \(error.localizedDescription)")
        
        if let nsError = error as NSError? {
            logger.error("\(indent)NSError domain: \(nsError.domain)")
            logger.error("\(indent)NSError code: \(nsError.code)")
            
            if !nsError.userInfo.isEmpty {
                logger.error("\(indent)NSError userInfo:")
                for (key, value) in nsError.userInfo {
                    logger.error("\(indent)  \(key): \(value)")
                    
                    // Recursively log underlying errors
                    if let underlyingError = value as? Error {
                        logger.error("\(indent)  → Underlying error found:")
                        logFullErrorStructure(underlyingError, depth: depth + 1, maxDepth: maxDepth)
                    }
                }
            }
        }
        
        // Try to extract using reflection
        let mirror = Mirror(reflecting: error)
        if !mirror.children.isEmpty {
            logger.error("\(indent)Error properties:")
            for child in mirror.children {
                let label = child.label ?? "unknown"
                logger.error("\(indent)  \(label): \(type(of: child.value))")
                
                if let underlyingError = child.value as? Error {
                    logger.error("\(indent)  → Underlying error found in property '\(label)':")
                    logFullErrorStructure(underlyingError, depth: depth + 1, maxDepth: maxDepth)
                }
            }
        }
    }
    
    /// Log detailed DecodingError information
    private func logDecodingErrorDetails(_ error: DecodingError) {
        logger.error("═══════════════════════════════════════════════════")
        logger.error("🔴 DECODING ERROR DETECTED:")
        logger.error("═══════════════════════════════════════════════════")
        
        switch error {
        case .typeMismatch(let type, let context):
            logger.error("🔴 Type mismatch")
            logger.error("Expected type: \(type)")
            logger.error("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.error("Debug description: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            logger.error("🔴 Value not found")
            logger.error("Expected type: \(type)")
            logger.error("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.error("Debug description: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            logger.error("🔴 Key not found")
            logger.error("Missing key: \(key.stringValue)")
            logger.error("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.error("Debug description: \(context.debugDescription)")
        case .dataCorrupted(let context):
            logger.error("🔴 Data corrupted (likely additionalProperties issue)")
            logger.error("Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            logger.error("Debug description: \(context.debugDescription)")
            
            // Extract additional properties information from debug description
            let debugDesc = context.debugDescription
            if debugDesc.contains("additionalProperties") || debugDesc.contains("Additional properties") || debugDesc.contains("unknown keys") {
                logger.error("═══════════════════════════════════════════════════")
                logger.error("⚠️⚠️⚠️ ADDITIONAL PROPERTIES ERROR DETECTED ⚠️⚠️⚠️")
                logger.error("═══════════════════════════════════════════════════")
                
                // Try multiple patterns to extract field names
                var foundFields: [String] = []
                
                // Pattern 1: "found X unknown keys" or "found X unknown key"
                if let range = debugDesc.range(of: "found ") {
                    let afterFound = String(debugDesc[range.upperBound...])
                    // Try to find "unknown keys" or "unknown key"
                    if let keysRange = afterFound.range(of: " unknown key") ?? afterFound.range(of: " unknown keys") {
                        let beforeKeys = String(afterFound[..<keysRange.lowerBound])
                        // Extract number and try to find keys list
                        if let numberRange = beforeKeys.range(of: " ") {
                            let countStr = String(beforeKeys[..<numberRange.lowerBound])
                            logger.error("⚠️ Number of unknown fields: \(countStr)")
                        }
                    }
                }
                
                // Pattern 2: Look for quoted field names in the error message
                // Example: "found 1 unknown keys during decoding (underlying error: <nil>)"
                // Or: "Additional properties are disabled, but found 6 unknown keys: [\"field1\", \"field2\"]"
                let fieldPattern = #"["']([^"']+)["']"#
                if let regex = try? NSRegularExpression(pattern: fieldPattern, options: []) {
                    let nsString = debugDesc as NSString
                    let matches = regex.matches(in: debugDesc, options: [], range: NSRange(location: 0, length: nsString.length))
                    for match in matches {
                        if match.numberOfRanges > 1 {
                            let fieldName = nsString.substring(with: match.range(at: 1))
                            foundFields.append(fieldName)
                        }
                    }
                }
                
                // Pattern 3: Look for field names after "keys:" or "key:"
                if let keysRange = debugDesc.range(of: "keys:") ?? debugDesc.range(of: "key:") {
                    let afterKeys = String(debugDesc[keysRange.upperBound...])
                    // Try to extract from array-like format: ["field1", "field2"] or [field1, field2]
                    if let arrayStart = afterKeys.range(of: "["), let arrayEnd = afterKeys.range(of: "]") {
                        let arrayContent = String(afterKeys[arrayStart.upperBound..<arrayEnd.lowerBound])
                        // Split by comma and clean up
                        let fields = arrayContent.split(separator: ",").map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"'\"")) }
                        foundFields.append(contentsOf: fields)
                    }
                }
                
                // Pattern 4: Try to extract from StringKey format
                // Example: "at StringKey(stringValue: \"fieldName\", intValue: nil)"
                let stringKeyPattern = #"StringKey\(stringValue:\s*"([^"]+)""#
                if let regex = try? NSRegularExpression(pattern: stringKeyPattern, options: []) {
                    let nsString = debugDesc as NSString
                    let matches = regex.matches(in: debugDesc, options: [], range: NSRange(location: 0, length: nsString.length))
                    for match in matches {
                        if match.numberOfRanges > 1 {
                            let fieldName = nsString.substring(with: match.range(at: 1))
                            if !foundFields.contains(fieldName) {
                                foundFields.append(fieldName)
                            }
                        }
                    }
                }
                
                // Log found fields
                if !foundFields.isEmpty {
                    logger.error("⚠️⚠️⚠️ UNKNOWN FIELDS CAUSING ERROR: ⚠️⚠️⚠️")
                    for (index, field) in foundFields.enumerated() {
                        logger.error("  \(index + 1). '\(field)'")
                    }
                } else {
                    logger.error("⚠️ Could not extract field names from error message")
                    logger.error("⚠️ Full debug description for manual inspection:")
                    logger.error("   \(debugDesc)")
                }
                
                // Try to extract from underlying error
                if let underlyingError = context.underlyingError {
                    logger.error("═══════════════════════════════════════════════════")
                    logger.error("📋 Underlying Error Details:")
                    logger.error("═══════════════════════════════════════════════════")
                    logger.error("Underlying error: \(underlyingError)")
                    logger.error("Underlying error type: \(type(of: underlyingError))")
                    
                    if let nsError = underlyingError as NSError? {
                        logger.error("NSError domain: \(nsError.domain)")
                        logger.error("NSError code: \(nsError.code)")
                        logger.error("NSError userInfo:")
                        for (key, value) in nsError.userInfo {
                            logger.error("  \(key): \(value)")
                            
                            // Try to extract field names from userInfo values
                            if let valueStr = value as? String {
                                // Check if value contains field names
                                if valueStr.contains("\"") || valueStr.contains("'") {
                                    let fieldPattern = #"["']([^"']+)["']"#
                                    if let regex = try? NSRegularExpression(pattern: fieldPattern, options: []) {
                                        let nsString = valueStr as NSString
                                        let matches = regex.matches(in: valueStr, options: [], range: NSRange(location: 0, length: nsString.length))
                                        for match in matches {
                                            if match.numberOfRanges > 1 {
                                                let fieldName = nsString.substring(with: match.range(at: 1))
                                                if !foundFields.contains(fieldName) {
                                                    foundFields.append(fieldName)
                                                    logger.error("    ⚠️ Found field name in userInfo: '\(fieldName)'")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Final summary
                if !foundFields.isEmpty {
                    logger.error("═══════════════════════════════════════════════════")
                    logger.error("🔴 SUMMARY - Fields causing additionalProperties error:")
                    for field in foundFields {
                        logger.error("   ❌ '\(field)'")
                    }
                    logger.error("═══════════════════════════════════════════════════")
                }
            }
        @unknown default:
            logger.error("Unknown decoding error: \(error)")
        }
        
        logger.error("═══════════════════════════════════════════════════")
    }
}



