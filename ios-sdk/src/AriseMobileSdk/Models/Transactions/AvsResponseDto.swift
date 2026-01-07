import Foundation

/// AVS (Address Verification System) response details returned by the ARISE API.
///
/// Provides granular information about the AVS verification result.
public struct AvsResponseDto: Equatable {
    /// Identifier describing the AVS action to take on the transaction.
    public let actionId: AvsAction?

    /// Human-readable AVS action description.
    public let action: String?

    /// AVS response code returned by the processor.
    public let responseCode: String?

    /// Identifier describing the AVS response code grouping.
    public let groupId: AvsCodeGroupType?

    /// Human-readable AVS code group name.
    public let group: String?

    /// Identifier describing the AVS result (e.g., Passed, Failed).
    public let resultId: AvsResponseResult?

    /// Human-readable AVS result description.
    public let result: String?

    /// Friendly description of the AVS response code.
    public let codeDescription: String?

    public init(
        actionId: AvsAction? = nil,
        action: String? = nil,
        responseCode: String? = nil,
        groupId: AvsCodeGroupType? = nil,
        group: String? = nil,
        resultId: AvsResponseResult? = nil,
        result: String? = nil,
        codeDescription: String? = nil
    ) {
        self.actionId = actionId
        self.action = action
        self.responseCode = responseCode
        self.groupId = groupId
        self.group = group
        self.resultId = resultId
        self.result = result
        self.codeDescription = codeDescription
    }
}

/// Action to take based on the AVS evaluation.
///
public enum AvsAction: Int, Equatable {
    case noMatch = 1
    case partialMatch = 2
}

/// Grouping of AVS response codes.
///
public enum AvsCodeGroupType: Int, Equatable {
    case noMatch = 1
    case partialMatch = 2
    case incompatible = 3
    case unavailable = 4
    case validGroup = 5
}

/// Result of the AVS verification.
///
public enum AvsResponseResult: Int, Equatable {
    case passed = 1
    case failed = 2
}
