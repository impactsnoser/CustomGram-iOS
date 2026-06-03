import Foundation

public enum CustomGramFeatureGates {
    private static let lock = NSLock()
    private static var cachedPreferences = CustomGramKeychain.load()
    private static var storageBasePath: String?

    public static func bootstrap(basePath: String) {
        lock.lock()
        cachedPreferences = CustomGramKeychain.load()
        storageBasePath = basePath
        MessageVaultStore.shared.configure(basePath: basePath)
        lock.unlock()
    }

    public static func reloadPreferences() {
        lock.lock()
        cachedPreferences = CustomGramKeychain.load()
        lock.unlock()
    }

    public static func updatePreferences(_ transform: (inout CustomGramPreferences) -> Void) {
        lock.lock()
        var preferences = cachedPreferences
        transform(&preferences)
        cachedPreferences = preferences
        CustomGramKeychain.save(preferences)
        lock.unlock()
    }

    public static var preferences: CustomGramPreferences {
        lock.lock()
        defer { lock.unlock() }
        return cachedPreferences
    }

    public static var ghostModeEnabled: Bool { preferences.ghostModeEnabled }
    public static var vaultEnabled: Bool { preferences.vaultEnabled }
    public static var showPeerIds: Bool { preferences.showPeerIds }
    public static var allowRestrictedCapture: Bool { preferences.allowRestrictedCapture }
    public static var unlimitedAccountsEnabled: Bool { preferences.unlimitedAccounts }

    public static var shouldSendReadReceipts: Bool { !ghostModeEnabled }
    public static var shouldSendTyping: Bool { !ghostModeEnabled }
    public static var shouldUpdateOnlineStatus: Bool { !ghostModeEnabled }

    public static var maximumNumberOfAccounts: Int {
        unlimitedAccountsEnabled ? 64 : 3
    }

    public static var maximumPremiumNumberOfAccounts: Int {
        unlimitedAccountsEnabled ? 64 : 4
    }
}
