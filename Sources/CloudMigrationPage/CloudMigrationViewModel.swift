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
    private let _itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

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

    init(coordinator: CloudMigrationCoordinator) {
        self.coordinator = coordinator

        (items, _itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        _itemsContinuation.yield(
            [
                .pageHeader(
                    headline: L10n.CloudMigration.title,
                    subheadline: L10n.CloudMigration.subtitle
                ),
                .cloudMigrationJot(
                    cloudMigrationJot: CloudMigrationJotBusinessModel(
                        previewImage: nil,
                        name: "Project Brainstorm",
                        lastModifiedText: "",
                        isCloudSynchronized: false
                    )
                ),
                .cloudMigrationJot(
                    cloudMigrationJot: CloudMigrationJotBusinessModel(
                        previewImage: nil,
                        name: "Final Sketch",
                        lastModifiedText: "",
                        isCloudSynchronized: false
                    )
                ),
                .cloudMigrationJot(
                    cloudMigrationJot: CloudMigrationJotBusinessModel(
                        previewImage: nil,
                        name: "Calculator Pro",
                        lastModifiedText: "",
                        isCloudSynchronized: true
                    )
                ),
            ]
        )
    }

    private func didTapItem(index: Int) {}

    private func didTapDoneButton() {
        coordinator?.dismiss()
    }
}
