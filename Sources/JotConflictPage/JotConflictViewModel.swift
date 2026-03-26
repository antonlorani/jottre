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
final class JotConflictViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageCellItem]>
    private let _itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.JotConflict.Action.keepVersionA,
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionA()
        },
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.JotConflict.Action.keepVersionB,
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionB()
        },
        PageCallToActionView.ActionConfiguration(
            style: .secondary,
            title: L10n.JotConflict.Action.keepBoth,
            icon: nil
        ) { [weak self] in
            self?.didTapKeepBoth()
        },
    ]

    private weak var coordinator: JotConflictCoordinator?

    init(coordinator: JotConflictCoordinator) {
        self.coordinator = coordinator

        (items, _itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        _itemsContinuation.yield([
            .pageHeader(
                headline: L10n.JotConflict.title,
                subheadline: L10n.JotConflict.subtitle("Sketch Final")
            ),
            .jot(
                jot: JotBusinessModel(
                    previewImage: nil,
                    name: "Version A",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "This Device - now",
                jotMenuConfigurations: [],
                sizing: .equalSplit(perRow: 2, itemHeight: 250),
                onAction: { /* no-op */  }
            ),
            .jot(
                jot: JotBusinessModel(
                    previewImage: nil,
                    name: "Version B",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "iPhone - 3:08 pm",
                jotMenuConfigurations: [],
                sizing: .equalSplit(perRow: 2, itemHeight: 250),
                onAction: { /* no-op */  }
            ),
        ])
    }

    private func didTapKeepVersionA() {
        coordinator?.dismiss()
    }

    private func didTapKeepVersionB() {
        coordinator?.dismiss()
    }

    private func didTapKeepBoth() {
        coordinator?.dismiss()
    }
}
