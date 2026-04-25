/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import OSLog
import UIKit

@MainActor
final class SceneCoordinator {

    enum Constants {
        static let activityType = "com.antonlorani.jottre.openJot"
        static let urlKey = "url"
        static let fileBookmarkKey = "fileBookmark"
    }

    private var lastActiveURL: URL?
    private var navigationController: UINavigationController?
    private var retainedRootCoordinator: NavigationCoordinator?
    private var userInterfaceStyleTask: Task<Void, Never>?

    private let navigation: Navigation
    private let defaultsService: DefaultsServiceProtocol
    private let applicationService: ApplicationServiceProtocol
    private let localFileService: FileServiceProtocol
    private let ubiquitousFileService: FileServiceProtocol
    private let logger: Logger
    private let rootCoordinatorFactory: RootCoordinatorFactoryProtocol
    private let editJotCoordinatorFactory: EditJotCoordinatorFactoryProtocol
    private let onUpdateUserInterfaceStyle: @Sendable (_ userInterfaceStyle: UIUserInterfaceStyle) -> Void
    private let requestSceneSessionActivationProvider: @Sendable (_ url: URL) -> Void

    init(
        navigation: Navigation,
        defaultsService: DefaultsServiceProtocol,
        applicationService: ApplicationServiceProtocol,
        localFileService: FileServiceProtocol,
        ubiquitousFileService: FileServiceProtocol,
        logger: Logger,
        rootCoordinatorFactory: RootCoordinatorFactoryProtocol,
        editJotCoordinatorFactory: EditJotCoordinatorFactoryProtocol,
        onUpdateUserInterfaceStyle: @Sendable @escaping (_ userInterfaceStyle: UIUserInterfaceStyle) -> Void,
        requestSceneSessionActivationProvider: @Sendable @escaping (_ url: URL) -> Void
    ) {
        self.navigation = navigation
        self.defaultsService = defaultsService
        self.applicationService = applicationService
        self.localFileService = localFileService
        self.ubiquitousFileService = ubiquitousFileService
        self.logger = logger
        self.rootCoordinatorFactory = rootCoordinatorFactory
        self.editJotCoordinatorFactory = editJotCoordinatorFactory
        self.onUpdateUserInterfaceStyle = onUpdateUserInterfaceStyle
        self.requestSceneSessionActivationProvider = requestSceneSessionActivationProvider
    }

    func handle(url: URL) -> [UIViewController] {
        lastActiveURL = url
        return retainedRootCoordinator?.handle(url: url) ?? []
    }

    func handle(
        session: UISceneSession,
        connectionOptions: UIScene.ConnectionOptions
    ) -> [UIViewController] {
        let url: URL
        let coordinator: NavigationCoordinator

        if let (activityURL, isRestored) = getActivityURL(session: session, connectionOptions: connectionOptions) {
            lazy var editJotCoordinator = editJotCoordinatorFactory.make(navigation: navigation)
            lazy var rootCoordinator = rootCoordinatorFactory.make(navigation: navigation)

            let preferredCoordinator: NavigationCoordinator
            if isEditJotURL(url: activityURL) {
                preferredCoordinator = editJotCoordinator
                url = activityURL
            } else if let editJotURL = makeEditJotURL(fileURL: activityURL) {
                preferredCoordinator = editJotCoordinator
                url = editJotURL
            } else {
                preferredCoordinator = rootCoordinator
                url = activityURL
            }

            if isRestored {
                #if targetEnvironment(macCatalyst)
                coordinator = preferredCoordinator
                #else
                // On iPadOS its more tedious for users to create a new fresh window. Therefore we prefer
                // restoring a scene that allows navigating back to a jots overview (When the activityURL
                // opens a nested hierarchy).
                coordinator = rootCoordinator
                #endif
            } else {
                if applicationService.supportsMultipleScenes() {
                    coordinator = preferredCoordinator
                } else {
                    coordinator = rootCoordinator
                }
            }
        } else {
            url = JotsPageURL().toURL()
            coordinator = rootCoordinatorFactory.make(navigation: navigation)
        }

        lastActiveURL = url
        retainedRootCoordinator = coordinator

        userInterfaceStyleTask?.cancel()
        userInterfaceStyleTask = Task {
            for await userInterfaceStyle in defaultsService.getValueStream(.userInterfaceStyle) {
                let userInterfaceStyle =
                    userInterfaceStyle
                    .flatMap(UIUserInterfaceStyle.init(rawValue:)) ?? .unspecified
                onUpdateUserInterfaceStyle(userInterfaceStyle)
            }
        }

        Task.detached { [weak self] in
            guard let self else {
                return
            }
            do {
                try await localFileService.initializeDocumentsDirectory()
                try await ubiquitousFileService.initializeDocumentsDirectory()
                logger.info("Initialized documents directories.")
            } catch {
                logger.error("Failed to initialize documents directory: \(error)")
            }
        }

        return coordinator.handle(url: url)
    }

    func handleURLContexts(
        urlContexts: Set<UIOpenURLContext>
    ) {
        guard let incomingURL = urlContexts.first?.url else {
            return
        }
        guard incomingURL.pathExtension == JotFile.Info.fileExtension else {
            navigation.open(url: incomingURL)
            return
        }
        openScene(url: incomingURL)
    }

    func openScene(url: URL) {
        if applicationService.supportsMultipleScenes() {
            requestSceneSessionActivationProvider(url)
        } else {
            navigation.open(url: url)
        }
    }

    func handlePop() {
        lastActiveURL = nil
    }

    func makeStateRestorationActivity() -> NSUserActivity? {
        guard
            let lastActiveURL,
            applicationService.supportsMultipleScenes()
        else {
            return nil
        }
        let activity = NSUserActivity(activityType: Constants.activityType)
        activity.userInfo = makeUserInfo(lastActiveURL: lastActiveURL)
        return activity
    }

    private func makeUserInfo(lastActiveURL: URL) -> [AnyHashable: Any] {
        var userInfo: [AnyHashable: Any] = [Constants.urlKey: lastActiveURL.absoluteString]
        if let fileURL = EditJotURL(url: lastActiveURL)?.fileURL,
            let bookmark = try? fileURL.bookmarkData()
        {
            userInfo[Constants.fileBookmarkKey] = bookmark
        }
        return userInfo
    }

    private func getActivityURL(
        session: UISceneSession,
        connectionOptions: UIScene.ConnectionOptions
    ) -> (url: URL, isRestored: Bool)? {
        if let activity = session.stateRestorationActivity,
            let url = getURL(activity: activity)
        {
            return (url: url, isRestored: true)
        }

        if let activity = connectionOptions.userActivities.first(where: { $0.activityType == Constants.activityType }),
            let url = getURL(activity: activity)
        {
            return (url: url, isRestored: false)
        }

        if let firstURLContextURL = connectionOptions.urlContexts.first?.url {
            return (url: firstURLContextURL, isRestored: false)
        }

        return nil
    }

    private func getURL(activity: NSUserActivity) -> URL? {
        guard
            activity.activityType == Constants.activityType,
            let urlString = activity.userInfo?[Constants.urlKey] as? String,
            let url = URL(string: urlString)
        else {
            return nil
        }

        guard
            let bookmark = activity.userInfo?[Constants.fileBookmarkKey] as? Data
        else {
            return url
        }

        var isStale = false
        guard
            let resolved = try? URL(
                resolvingBookmarkData: bookmark,
                bookmarkDataIsStale: &isStale
            ),
            EditJotURL(url: url) != nil,
            let rebuilt = makeEditJotURL(fileURL: resolved)
        else {
            return url
        }
        return rebuilt
    }

    private func isEditJotURL(url: URL) -> Bool {
        EditJotURL(url: url) != nil
    }

    private func makeEditJotURL(fileURL: URL) -> URL? {
        guard
            let jotFileInfo = JotFile.Info(
                url: fileURL,
                modificationDate: nil,
                ubiquitousInfo: nil
            )
        else {
            return nil
        }
        return EditJotURL(jotFileInfo: jotFileInfo).toURL()
    }

    deinit {
        userInterfaceStyleTask?.cancel()
    }
}
