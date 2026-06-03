import Foundation
import Postbox

public struct VaultMessageSnapshot: Codable, Equatable {
    public let peerId: Int64
    public let namespace: Int32
    public let messageId: Int32
    public let text: String
    public let timestamp: Int32
    public let authorPeerId: Int64?
    public let isDeleted: Bool
    public let isEdited: Bool
    public let originalText: String?

    public var messageIdValue: MessageId {
        MessageId(
            peerId: PeerId(peerId),
            namespace: namespace,
            id: messageId
        )
    }
}

public final class MessageVaultStore {
    public static let shared = MessageVaultStore()

    private let lock = NSLock()
    private var basePath: String?
    private var snapshots: [String: VaultMessageSnapshot] = [:]

    private init() {}

    public func configure(basePath: String) {
        lock.lock()
        self.basePath = basePath
        self.ensureDirectory()
        self.loadFromDisk()
        lock.unlock()
    }

    private var fileURL: URL? {
        guard let basePath else {
            return nil
        }
        return URL(fileURLWithPath: basePath).appendingPathComponent("customgram/vault.json")
    }

    private func ensureDirectory() {
        guard let fileURL else {
            return
        }
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    private func key(for messageId: MessageId) -> String {
        "\(messageId.peerId.toInt64())_\(messageId.namespace)_\(messageId.id)"
    }

    private func loadFromDisk() {
        guard let fileURL,
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: VaultMessageSnapshot].self, from: data)
        else {
            return
        }
        self.snapshots = decoded
    }

    private func persistLocked() {
        guard let fileURL,
              let data = try? JSONEncoder().encode(self.snapshots)
        else {
            return
        }
        try? data.write(to: fileURL, options: [.atomic])
    }

    public func snapshot(for messageId: MessageId) -> VaultMessageSnapshot? {
        lock.lock()
        defer { lock.unlock() }
        return snapshots[key(for: messageId)]
    }

    public func recordDelete(from message: Message) {
        lock.lock()
        let snapshot = VaultMessageSnapshot(
            peerId: message.id.peerId.toInt64(),
            namespace: message.id.namespace,
            messageId: message.id.id,
            text: message.text,
            timestamp: message.timestamp,
            authorPeerId: message.author?.id.toInt64(),
            isDeleted: true,
            isEdited: false,
            originalText: nil
        )
        snapshots[key(for: message.id)] = snapshot
        persistLocked()
        lock.unlock()
    }

    public func recordEdit(messageId: MessageId, previousText: String, currentText: String, timestamp: Int32, authorPeerId: Int64?) {
        lock.lock()
        let snapshot = VaultMessageSnapshot(
            peerId: messageId.peerId.toInt64(),
            namespace: messageId.namespace,
            messageId: messageId.id,
            text: currentText,
            timestamp: timestamp,
            authorPeerId: authorPeerId,
            isDeleted: false,
            isEdited: true,
            originalText: previousText
        )
        snapshots[key(for: messageId)] = snapshot
        persistLocked()
        lock.unlock()
    }
}
