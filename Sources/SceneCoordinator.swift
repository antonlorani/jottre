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

import UIKit

@MainActor
final class SceneCoordinator {

    enum Constants {
        static let activityType = "com.antonlorani.jottre.openJot"
        static let urlKey = "url"
    }

    private var lastActiveURL: URL?
    private var navigationController: UINavigationController?
    private var retainedRootCoordinator: NavigationCoordinator?
    private var userInterfaceStyleTask: Task<Void, Never>?

    private let navigation: Navigation
    private let defaultsService: DefaultsServiceProtocol
    private let applicationService: ApplicationServiceProtocol
    private let ubiquitousFileService: UbiquitousFileService
    private let rootCoordinatorFactory: RootCoordinatorFactoryProtocol
    private let editJotCoordinatorFactory: EditJotCoordinatorFactoryProtocol
    private let onUpdateUserInterfaceStyle: @Sendable (_ userInterfaceStyle: UIUserInterfaceStyle) -> Void
    private let requestSceneSessionActivationProvider: @Sendable (_ url: URL) -> Void

    init(
        navigation: Navigation,
        defaultsService: DefaultsServiceProtocol,
        applicationService: ApplicationServiceProtocol,
        ubiquitousFileService: UbiquitousFileService,
        rootCoordinatorFactory: RootCoordinatorFactoryProtocol,
        editJotCoordinatorFactory: EditJotCoordinatorFactoryProtocol,
        onUpdateUserInterfaceStyle: @Sendable @escaping (_ userInterfaceStyle: UIUserInterfaceStyle) -> Void,
        requestSceneSessionActivationProvider: @Sendable @escaping (_ url: URL) -> Void
    ) {
        self.navigation = navigation
        self.defaultsService = defaultsService
        self.applicationService = applicationService
        self.ubiquitousFileService = ubiquitousFileService
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

        if let (startURL, isRestored) = getStartURL(session: session, connectionOptions: connectionOptions) {
            url = startURL

            if isRestored {
                coordinator = rootCoordinatorFactory.make(navigation: navigation)
            } else {
                if applicationService.supportsMultipleScenes() {
                    coordinator = editJotCoordinatorFactory.make(navigation: navigation)
                } else {
                    coordinator = rootCoordinatorFactory.make(navigation: navigation)
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

    func makeStateRestorationActivity() -> NSUserActivity? {
        guard
            let lastActiveURL,
            applicationService.supportsMultipleScenes()
        else {
            return nil
        }
        let activity = NSUserActivity(activityType: Constants.activityType)
        activity.userInfo = [
            Constants.urlKey: lastActiveURL.absoluteString
        ]
        return activity
    }

    private func getStartURL(
        session: UISceneSession,
        connectionOptions: UIScene.ConnectionOptions
    ) -> (url: URL, isRestored: Bool)? {
        if let activity = session.stateRestorationActivity,
            activity.activityType == Constants.activityType,
            let urlString = activity.userInfo?[Constants.urlKey] as? String,
            let url = URL(string: urlString)
        {
            return (
                url: makeEditJotURL(url: url) ?? url,
                isRestored: true
            )
        }

        if let activity = connectionOptions.userActivities.first(where: { $0.activityType == Constants.activityType }),
            let urlString = activity.userInfo?[Constants.urlKey] as? String,
            let url = URL(string: urlString)
        {
            return (
                url: makeEditJotURL(url: url) ?? url,
                isRestored: false
            )
        }

        if let firstURLContextURL = connectionOptions.urlContexts.first?.url {
            return (
                url: makeEditJotURL(url: firstURLContextURL) ?? firstURLContextURL,
                isRestored: false
            )
        }

        return nil
    }

    private func makeEditJotURL(url: URL) -> URL? {
        guard
            let jotFileInfo = JotFile.Info(
                url: url,
                modificationDate: nil,
                ubiquitousInfo: ubiquitousFileService.ubiquitousInfo(url: url)
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
