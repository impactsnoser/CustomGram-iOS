import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import Postbox
import AccountContext
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import CustomGramCore

private final class CustomGramSettingsControllerArguments {
    let updateGhostMode: (Bool) -> Void
    let updateVault: (Bool) -> Void
    let updateShowPeerIds: (Bool) -> Void
    let updateAllowRestrictedCapture: (Bool) -> Void
    let updateUnlimitedAccounts: (Bool) -> Void

    init(
        updateGhostMode: @escaping (Bool) -> Void,
        updateVault: @escaping (Bool) -> Void,
        updateShowPeerIds: @escaping (Bool) -> Void,
        updateAllowRestrictedCapture: @escaping (Bool) -> Void,
        updateUnlimitedAccounts: @escaping (Bool) -> Void
    ) {
        self.updateGhostMode = updateGhostMode
        self.updateVault = updateVault
        self.updateShowPeerIds = updateShowPeerIds
        self.updateAllowRestrictedCapture = updateAllowRestrictedCapture
        self.updateUnlimitedAccounts = updateUnlimitedAccounts
    }
}

private enum CustomGramSettingsSection: Int32 {
    case main
}

private enum CustomGramSettingsEntry: ItemListNodeEntry {
    case ghostMode(PresentationTheme, String, Bool)
    case vault(PresentationTheme, String, Bool)
    case showPeerIds(PresentationTheme, String, Bool)
    case allowRestrictedCapture(PresentationTheme, String, Bool)
    case unlimitedAccounts(PresentationTheme, String, Bool)
    case info(PresentationTheme, String)

    var section: ItemListSectionId {
        return CustomGramSettingsSection.main.rawValue
    }

    var stableId: Int32 {
        switch self {
        case .ghostMode:
            return 0
        case .vault:
            return 1
        case .showPeerIds:
            return 2
        case .allowRestrictedCapture:
            return 3
        case .unlimitedAccounts:
            return 4
        case .info:
            return 5
        }
    }

    static func == (lhs: CustomGramSettingsEntry, rhs: CustomGramSettingsEntry) -> Bool {
        switch lhs {
        case let .ghostMode(lhsTheme, lhsText, lhsValue):
            if case let .ghostMode(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .vault(lhsTheme, lhsText, lhsValue):
            if case let .vault(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .showPeerIds(lhsTheme, lhsText, lhsValue):
            if case let .showPeerIds(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .allowRestrictedCapture(lhsTheme, lhsText, lhsValue):
            if case let .allowRestrictedCapture(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .unlimitedAccounts(lhsTheme, lhsText, lhsValue):
            if case let .unlimitedAccounts(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            } else {
                return false
            }
        case let .info(lhsTheme, lhsText):
            if case let .info(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            } else {
                return false
            }
        }
    }

    static func < (lhs: CustomGramSettingsEntry, rhs: CustomGramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! CustomGramSettingsControllerArguments
        switch self {
        case let .ghostMode(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateGhostMode(value)
                }
            )
        case let .vault(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateVault(value)
                }
            )
        case let .showPeerIds(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateShowPeerIds(value)
                }
            )
        case let .allowRestrictedCapture(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateAllowRestrictedCapture(value)
                }
            )
        case let .unlimitedAccounts(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                systemStyle: .glass,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.updateUnlimitedAccounts(value)
                }
            )
        case let .info(_, text):
            return ItemListTextItem(
                presentationData: presentationData,
                text: .plain(text),
                sectionId: self.section
            )
        }
    }
}

private struct CustomGramSettingsState: Equatable {
    var preferences: CustomGramPreferences
}

private func customGramSettingsEntries(presentationData: PresentationData, state: CustomGramSettingsState) -> [CustomGramSettingsEntry] {
    var entries: [CustomGramSettingsEntry] = []
    entries.append(.ghostMode(presentationData.theme, "Ghost Mode (без read receipts)", state.preferences.ghostModeEnabled))
    entries.append(.vault(presentationData.theme, "Message Vault (анти-удаление)", state.preferences.vaultEnabled))
    entries.append(.showPeerIds(presentationData.theme, "Показывать Telegram ID", state.preferences.showPeerIds))
    entries.append(.allowRestrictedCapture(presentationData.theme, "Разрешить скриншоты (риск бана)", state.preferences.allowRestrictedCapture))
    entries.append(.unlimitedAccounts(presentationData.theme, "Неограниченные аккаунты", state.preferences.unlimitedAccounts))
    entries.append(.info(presentationData.theme, "CustomGram power-user функции. Используйте осознанно — некоторые опции могут нарушать ожидания собеседников и правила Telegram."))
    return entries
}

public func customGramSettingsController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences), ignoreRepeated: true)
    let stateValue = Atomic(value: CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences))

    let updateState: ((CustomGramSettingsState) -> CustomGramSettingsState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }

    let arguments = CustomGramSettingsControllerArguments(
        updateGhostMode: { value in
            CustomGramFeatureGates.updatePreferences { $0.ghostModeEnabled = value }
            updateState { CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences) }
        },
        updateVault: { value in
            CustomGramFeatureGates.updatePreferences { $0.vaultEnabled = value }
            updateState { CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences) }
        },
        updateShowPeerIds: { value in
            CustomGramFeatureGates.updatePreferences { $0.showPeerIds = value }
            updateState { CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences) }
        },
        updateAllowRestrictedCapture: { value in
            CustomGramFeatureGates.updatePreferences { $0.allowRestrictedCapture = value }
            updateState { CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences) }
        },
        updateUnlimitedAccounts: { value in
            CustomGramFeatureGates.updatePreferences { $0.unlimitedAccounts = value }
            updateState { CustomGramSettingsState(preferences: CustomGramFeatureGates.preferences) }
        }
    )

    let signal = combineLatest(
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("CustomGram"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back)
        )
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: customGramSettingsEntries(presentationData: presentationData, state: state),
            style: .blocks,
            animateChanges: false
        )
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
