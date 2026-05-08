import UIKit

@testable import Jottre

@MainActor
final class JotsCoordinatorMock: JotsCoordinatorProtocol {

    private let shouldHandleProvider: (_ url: URL) -> Bool
    private let handleProvider: (_ url: URL) -> [UIViewController]
    private let openSettingsProvider: () -> Void
    private let openCreateJotProvider: () -> Void
    private let openJotProvider: (_ jotFileInfo: JotFile.Info, _ prefersNewWindow: Bool) -> Void
    private let openEnableCloudPageProvider: () -> Void
    private let showShareJotProvider:
        (_ jotFileInfo: JotFile.Info, _ format: ShareFormat, _ configurePopoverAnchor: PopoverAnchor?) -> Void
    private let showRenameAlertProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let openDeleteJotProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void
    private let showInFilesProvider: (_ jotFileInfo: JotFile.Info) -> Void

    init(
        shouldHandleProvider: @escaping (_ url: URL) -> Bool = { _ in false },
        handleProvider: @escaping (_ url: URL) -> [UIViewController] = { _ in [] },
        openSettingsProvider: @escaping () -> Void = {},
        openCreateJotProvider: @escaping () -> Void = {},
        openJotProvider: @escaping (_ jotFileInfo: JotFile.Info, _ prefersNewWindow: Bool) -> Void = { _, _ in },
        openEnableCloudPageProvider: @escaping () -> Void = {},
        showShareJotProvider:
            @escaping (_ jotFileInfo: JotFile.Info, _ format: ShareFormat, _ configurePopoverAnchor: PopoverAnchor?) ->
            Void = { _, _, _ in },
        showRenameAlertProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        openDeleteJotProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in },
        showInFilesProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in }
    ) {
        self.shouldHandleProvider = shouldHandleProvider
        self.handleProvider = handleProvider
        self.openSettingsProvider = openSettingsProvider
        self.openCreateJotProvider = openCreateJotProvider
        self.openJotProvider = openJotProvider
        self.openEnableCloudPageProvider = openEnableCloudPageProvider
        self.showShareJotProvider = showShareJotProvider
        self.showRenameAlertProvider = showRenameAlertProvider
        self.openDeleteJotProvider = openDeleteJotProvider
        self.showInfoAlertProvider = showInfoAlertProvider
        self.showInFilesProvider = showInFilesProvider
    }

    func shouldHandle(url: URL) -> Bool {
        shouldHandleProvider(url)
    }

    func handle(url: URL) -> [UIViewController] {
        handleProvider(url)
    }

    func openSettings() { openSettingsProvider() }
    func openCreateJot() { openCreateJotProvider() }
    func openJot(jotFileInfo: JotFile.Info, prefersNewWindow: Bool) {
        openJotProvider(jotFileInfo, prefersNewWindow)
    }
    func openEnableCloudPage() { openEnableCloudPageProvider() }
    func showShareJot(
        jotFileInfo: JotFile.Info,
        format: ShareFormat,
        configurePopoverAnchor: PopoverAnchor?
    ) {
        showShareJotProvider(jotFileInfo, format, configurePopoverAnchor)
    }
    func showRenameAlert(jotFileInfo: JotFile.Info) {
        showRenameAlertProvider(jotFileInfo)
    }
    func openDeleteJot(jotFileInfo: JotFile.Info) {
        openDeleteJotProvider(jotFileInfo)
    }
    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }
    func showInFiles(jotFileInfo: JotFile.Info) {
        showInFilesProvider(jotFileInfo)
    }
}
