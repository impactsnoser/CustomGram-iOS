import Foundation

public struct CustomGramPreferences: Codable, Equatable {
    public var ghostModeEnabled: Bool
    public var vaultEnabled: Bool
    public var showPeerIds: Bool
    public var allowRestrictedCapture: Bool
    public var unlimitedAccounts: Bool

    public init(
        ghostModeEnabled: Bool = false,
        vaultEnabled: Bool = true,
        showPeerIds: Bool = true,
        allowRestrictedCapture: Bool = false,
        unlimitedAccounts: Bool = true
    ) {
        self.ghostModeEnabled = ghostModeEnabled
        self.vaultEnabled = vaultEnabled
        self.showPeerIds = showPeerIds
        self.allowRestrictedCapture = allowRestrictedCapture
        self.unlimitedAccounts = unlimitedAccounts
    }
}
