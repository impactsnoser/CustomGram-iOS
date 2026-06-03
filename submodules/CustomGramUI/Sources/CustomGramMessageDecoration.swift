import Foundation
import UIKit
import AsyncDisplayKit
import Display
import Postbox
import TelegramCore
import CustomGramCore

public enum CustomGramMessageDecoration {
    public static func apply(to node: ASDisplayNode, message: Message) {
        let isDeleted = CustomGramMessageAttributes.isDeleted(message)
        let hasEditedHistory = CustomGramMessageAttributes.editedOriginalText(message) != nil

        if isDeleted || hasEditedHistory {
            node.alpha = isDeleted ? 0.72 : 1.0
            node.borderWidth = isDeleted ? 1.0 : 0.0
            node.borderColor = isDeleted ? UIColor.systemRed.withAlphaComponent(0.25).cgColor : nil
        } else {
            node.alpha = 1.0
            node.borderWidth = 0.0
            node.borderColor = nil
        }
    }

    public static func badgeText(for message: Message) -> String? {
        if CustomGramMessageAttributes.isDeleted(message) {
            return "🗑️ удалено"
        }
        if let original = CustomGramMessageAttributes.editedOriginalText(message) {
            return "✏️ было: \(original)"
        }
        return nil
    }
}

public final class CustomGramVaultBadgeNode: ASDisplayNode {
    private let textNode = ASTextNode()

    override public init() {
        super.init()
        self.addSubnode(self.textNode)
        self.clipsToBounds = true
        self.cornerRadius = 8.0
        self.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.92)
    }

    public func update(message: Message, font: UIFont) {
        guard let text = CustomGramMessageDecoration.badgeText(for: message) else {
            self.isHidden = true
            return
        }

        self.isHidden = false
        self.textNode.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.secondaryLabel,
            ]
        )
    }

    public func measure(maxWidth: CGFloat) -> CGSize {
        guard !self.isHidden, let text = self.textNode.attributedText else {
            return .zero
        }
        let size = text.boundingRect(
            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        return CGSize(width: min(maxWidth, ceil(size.width) + 12.0), height: ceil(size.height) + 6.0)
    }

    public func layout(size: CGSize) {
        self.textNode.frame = CGRect(x: 6.0, y: 3.0, width: max(0.0, size.width - 12.0), height: max(0.0, size.height - 6.0))
    }
}
