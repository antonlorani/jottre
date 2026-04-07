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

enum ShareFormat {
    case pdf, jpg, png
}

final class ShareJotCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private var retainedInfoAlertCoordinator: Coordinator?
    private var exportTask: Task<Void, Never>?

    private let jotFileInfo: JotFile.Info
    private let format: ShareFormat
    private let navigation: Navigation
    private let repository: ShareJotRepositoryProtocol

    init(
        jotFileInfo: JotFile.Info,
        format: ShareFormat,
        navigation: Navigation,
        repository: ShareJotRepositoryProtocol
    ) {
        self.jotFileInfo = jotFileInfo
        self.format = format
        self.navigation = navigation
        self.repository = repository
    }

    func start() {
        exportTask = Task { [weak self] in
            guard let self else {
                return
            }
            do {
                let fileURL = try await repository.exportJot(
                    jotFileInfo: jotFileInfo,
                    format: format
                )
                presentActivityViewController(fileURL: fileURL)
            } catch {
                showInfoAlert(
                    title: L10n.Jots.Share.Error.generic(jotFileInfo.name),
                    message: error.localizedDescription
                )
            }
        }
    }

    private func presentActivityViewController(fileURL: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        activityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.navigation.dismiss(animated: true) {
                Task { @MainActor in
                    self?.onEnd?()
                }
            }
        }

        let containerViewController = UIViewController()
        containerViewController.modalPresentationStyle = .formSheet
        containerViewController.addChild(activityViewController)
        containerViewController.view.addSubview(activityViewController.view)
        activityViewController.view.frame = containerViewController.view.bounds
        activityViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityViewController.didMove(toParent: containerViewController)

        navigation.present(containerViewController, animated: true)
    }

    private func showInfoAlert(
        title: String,
        message: String?
    ) {
        let infoAlertCoordinator = InfoAlertCoordinator(
            navigation: navigation,
            title: title,
            message: message
        )
        retainedInfoAlertCoordinator = infoAlertCoordinator
        infoAlertCoordinator.onEnd = { [weak self] in
            self?.retainedInfoAlertCoordinator = nil
            self?.onEnd?()
        }
        infoAlertCoordinator.start()
    }

    deinit {
        exportTask?.cancel()
    }
}
