import Foundation
import Postbox

public enum CustomGramVaultDeletion {
    public static func softDeleteIds(from ids: [MessageId], transaction: Transaction) -> [MessageId] {
        guard CustomGramFeatureGates.vaultEnabled else {
            return ids
        }

        var hardDeleteIds: [MessageId] = []
        for id in ids {
            guard let message = transaction.getMessage(id) else {
                hardDeleteIds.append(id)
                continue
            }

            if CustomGramMessageAttributes.isDeleted(message) {
                hardDeleteIds.append(id)
                continue
            }

            MessageVaultStore.shared.recordDelete(from: message)

            let _ = transaction.updateMessage(id, update: { currentMessage in
                var storeForwardInfo: StoreMessageForwardInfo?
                if let forwardInfo = currentMessage.forwardInfo {
                    storeForwardInfo = StoreMessageForwardInfo(
                        authorId: forwardInfo.author?.id,
                        sourceId: forwardInfo.source?.id,
                        sourceMessageId: forwardInfo.sourceMessageId,
                        date: forwardInfo.date,
                        authorSignature: forwardInfo.authorSignature,
                        psaType: forwardInfo.psaType,
                        flags: forwardInfo.flags
                    )
                }

                var attributes = currentMessage.attributes.filter { !($0 is CustomGramDeletedMessageAttribute) }
                attributes.append(CustomGramDeletedMessageAttribute())

                return .update(StoreMessage(
                    id: currentMessage.id,
                    customStableId: currentMessage.customStableId,
                    globallyUniqueId: currentMessage.globallyUniqueId,
                    groupingKey: currentMessage.groupingKey,
                    threadId: currentMessage.threadId,
                    timestamp: currentMessage.timestamp,
                    flags: StoreMessageFlags(currentMessage.flags),
                    tags: currentMessage.tags,
                    globalTags: currentMessage.globalTags,
                    localTags: currentMessage.localTags,
                    forwardInfo: storeForwardInfo,
                    authorId: currentMessage.author?.id,
                    text: currentMessage.text,
                    attributes: attributes,
                    media: currentMessage.media
                ))
            })
        }

        return hardDeleteIds
    }
}
