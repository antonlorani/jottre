import UIKit

@testable import Jottre

@MainActor
final class EditJotCoordinatorMock: EditJotCoordinatorProtocol {

    private let shouldHandleProvider: (_ url: URL) -> Bool
    private let handleProvider: (_ url: URL) -> [UIViewController]
    private let showShareJotProvider:
        (_ jotFileInfo: JotFile.Info, _ format: ShareFormat, _ configurePopoverAnchor: PopoverAnchor?) -> Void
    private let showRenameAlertProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let openDeleteJotProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let openJotProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let showInFilesProvider: (_ jotFileInfo: JotFile.Info) -> Void
    private let showJotConflictPageProvider:
        (
            _ jotFileInfo: JotFile.Info,
            _ jotFileVersions: [JotFileVersion],
            _ onResult: @Sendable (_ result: JotConflictResult) -> Void
        ) -> Void
    private let canGoBackProvider: () -> Bool
    private let goBackProvider: () -> Void
    private let showInfoAlertProvider: (_ title: String, _ message: String) -> Void

    init(
        shouldHandleProvider: @escaping (_ url: URL) -> Bool = { _ in false },
        handleProvider: @escaping (_ url: URL) -> [UIViewController] = { _ in [] },
        showShareJotProvider:
            @escaping (_ jotFileInfo: JotFile.Info, _ format: ShareFormat, _ configurePopoverAnchor: PopoverAnchor?) ->
            Void = { _, _, _ in },
        showRenameAlertProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        openDeleteJotProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        openJotProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        showInFilesProvider: @escaping (_ jotFileInfo: JotFile.Info) -> Void = { _ in },
        showJotConflictPageProvider:
            @escaping (
                _ jotFileInfo: JotFile.Info,
                _ jotFileVersions: [JotFileVersion],
                _ onResult: @Sendable (_ result: JotConflictResult) -> Void
            ) -> Void = { _, _, _ in },
        canGoBackProvider: @escaping () -> Bool = { false },
        goBackProvider: @escaping () -> Void = {},
        showInfoAlertProvider: @escaping (_ title: String, _ message: String) -> Void = { _, _ in }
    ) {
        self.shouldHandleProvider = shouldHandleProvider
        self.handleProvider = handleProvider
        self.showShareJotProvider = showShareJotProvider
        self.showRenameAlertProvider = showRenameAlertProvider
        self.openDeleteJotProvider = openDeleteJotProvider
        self.openJotProvider = openJotProvider
        self.showInFilesProvider = showInFilesProvider
        self.showJotConflictPageProvider = showJotConflictPageProvider
        self.canGoBackProvider = canGoBackProvider
        self.goBackProvider = goBackProvider
        self.showInfoAlertProvider = showInfoAlertProvider
    }

    func shouldHandle(url: URL) -> Bool {
        shouldHandleProvider(url)
    }

    func handle(url: URL) -> [UIViewController] {
        handleProvider(url)
    }

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

    func openJot(jotFileInfo: JotFile.Info) {
        openJotProvider(jotFileInfo)
    }

    func showInFiles(jotFileInfo: JotFile.Info) {
        showInFilesProvider(jotFileInfo)
    }

    func showJotConflictPage(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) {
        showJotConflictPageProvider(jotFileInfo, jotFileVersions, onResult)
    }

    func canGoBack() -> Bool {
        canGoBackProvider()
    }

    func goBack() {
        goBackProvider()
    }

    func showInfoAlert(title: String, message: String) {
        showInfoAlertProvider(title, message)
    }
}
