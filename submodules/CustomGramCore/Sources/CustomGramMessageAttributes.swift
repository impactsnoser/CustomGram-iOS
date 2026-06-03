import Foundation
import Postbox

public final class CustomGramDeletedMessageAttribute: MessageAttribute, Equatable {
    public let deletedAt: Int32

    public var associatedPeerIds: [PeerId] {
        return []
    }

    public init(deletedAt: Int32 = Int32(Date().timeIntervalSince1970)) {
        self.deletedAt = deletedAt
    }

    public init(decoder: PostboxDecoder) {
        self.deletedAt = decoder.decodeInt32ForKey("d", orElse: 0)
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.deletedAt, forKey: "d")
    }

    public static func == (lhs: CustomGramDeletedMessageAttribute, rhs: CustomGramDeletedMessageAttribute) -> Bool {
        return lhs.deletedAt == rhs.deletedAt
    }
}

public final class CustomGramEditedMessageAttribute: MessageAttribute, Equatable {
    public let originalText: String
    public let editedAt: Int32

    public var associatedPeerIds: [PeerId] {
        return []
    }

    public init(originalText: String, editedAt: Int32 = Int32(Date().timeIntervalSince1970)) {
        self.originalText = originalText
        self.editedAt = editedAt
    }

    public init(decoder: PostboxDecoder) {
        self.originalText = decoder.decodeStringForKey("t", orElse: "")
        self.editedAt = decoder.decodeInt32ForKey("e", orElse: 0)
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeString(self.originalText, forKey: "t")
        encoder.encodeInt32(self.editedAt, forKey: "e")
    }

    public static func == (lhs: CustomGramEditedMessageAttribute, rhs: CustomGramEditedMessageAttribute) -> Bool {
        return lhs.originalText == rhs.originalText && lhs.editedAt == rhs.editedAt
    }
}

public enum CustomGramMessageAttributes {
    public static func isDeleted(_ message: Message) -> Bool {
        return message.attributes.contains(where: { $0 is CustomGramDeletedMessageAttribute })
    }

    public static func editedOriginalText(_ message: Message) -> String? {
        guard let attribute = message.attributes.first(where: { $0 is CustomGramEditedMessageAttribute }) as? CustomGramEditedMessageAttribute else {
            return nil
        }
        return attribute.originalText.isEmpty ? nil : attribute.originalText
    }
}
