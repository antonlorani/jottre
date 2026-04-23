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

import Foundation

@MainActor
final class CloudMigrationViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private let repository: CloudMigrationRepositoryProtocol
    private weak var coordinator: CloudMigrationCoordinator?

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.Action.done,
            icon: nil
        ) { [weak self] in
            self?.didTapDoneButton()
        }
    ]

    private var jotsTask: Task<Void, Never>?

    init(
        repository: CloudMigrationRepositoryProtocol,
        coordinator: CloudMigrationCoordinator
    ) {
        self.repository = repository
        self.coordinator = coordinator

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
    }

    func didLoad() {
        jotsTask = Task.detached { [weak self] in
            guard let self else {
                return
            }
            do {
                for try await cloudMigrationJots in repository.getJotFiles() {
                    await handleJots(cloudMigrationJots: cloudMigrationJots)
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleJots(cloudMigrationJots: [CloudMigrationJotBusinessModel]) {
        var items = [PageCellItem]()

        if cloudMigrationJots.isEmpty {
            items.append(
                contentsOf: [
                    PageCellItem.cloudImage(),
                    PageCellItem.pageHeader(
                        headline: L10n.CloudMigration.title,
                        subheadline: L10n.CloudMigration.NothingToMigrate.subtitle
                    ),
                ]
            )
        } else {
            items.append(
                PageCellItem.pageHeader(
                    headline: L10n.CloudMigration.title,
                    subheadline: L10n.CloudMigration.subtitle
                )
            )
            items.append(
                contentsOf: cloudMigrationJots.map { cloudMigrationJot in
                    PageCellItem.cloudMigrationJot(
                        cloudMigrationJot: cloudMigrationJot,
                        repository: repository,
                    ) { [weak self] in
                        Task { @MainActor in
                            self?.didTapCloudMigrationJot(cloudMigrationJot: cloudMigrationJot)
                        }
                    }
                }
            )
        }

        itemsContinuation.yield(items)
    }

    private func didTapCloudMigrationJot(
        cloudMigrationJot: CloudMigrationJotBusinessModel
    ) {
        Task.detached { [weak self] in
            do {
                try await self?.repository.moveJotFile(
                    jotFileInfo: cloudMigrationJot.toJotFileInfo(),
                    shouldBecomeUbiquitous: !cloudMigrationJot.isUbiquitous
                )
            } catch {
                await self?.coordinator?.showInfoAlert(
                    title: L10n.CloudMigration.ErrorAlert.title(cloudMigrationJot.name),
                    message: error.localizedDescription
                )
            }
        }
    }

    private func didTapDoneButton() {
        repository.markCloudMigrationPageDone()
        coordinator?.dismiss()
    }
}
