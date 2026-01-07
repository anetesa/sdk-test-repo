import Foundation

/// EMV tag set captured during chip-card processing.
///
/// Represents EMV TLV values that accompany a receipt.
public struct EmvTagsDto: Equatable {
    /// Application cryptogram (tag AC).
    public let ac: String?

    /// Terminal Verification Results (tag TVR).
    public let tvr: String?

    /// Transaction Status Information (tag TSI).
    public let tsi: String?

    /// Application identifier (tag AID).
    public let aid: String?

    /// Application label associated with the card.
    public let applicationLabel: String?

    /// Raw EMV tag/value pairs provided by the processor.
    /// - SeeAlso: `rawTagDictionary` for dictionary access
    public let rawTags: [RawTag]?

    public init(
        ac: String? = nil,
        tvr: String? = nil,
        tsi: String? = nil,
        aid: String? = nil,
        applicationLabel: String? = nil,
        rawTags: [RawTag]? = nil
    ) {
        self.ac = ac
        self.tvr = tvr
        self.tsi = tsi
        self.aid = aid
        self.applicationLabel = applicationLabel
        self.rawTags = rawTags
    }

    /// Convenience dictionary built from `rawTags`.
    public var rawTagDictionary: [String: String] {
        guard let rawTags else { return [:] }
        return rawTags.reduce(into: [String: String]()) { result, entry in
            result[entry.tag] = entry.value ?? ""
        }
    }

    /// Single EMV tag/value entry.
    ///
    public struct RawTag: Equatable {
        /// EMV tag identifier (hex-encoded).
        public let tag: String
        /// Tag value represented as a string.
        public let value: String?

        public init(tag: String, value: String?) {
            self.tag = tag
            self.value = value
        }
    }
}
