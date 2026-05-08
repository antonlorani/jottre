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
final class EnableCloudViewModel: PageViewModel, Sendable {

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private weak var coordinator: EnableCloudCoordinatorProtocol?

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.EnableCloud.Action.learnHowToEnable,
            icon: "arrow.up.forward"
        ) { [weak self] in
            self?.didTapLearnHowToEnable()
        }
    ]

    init(coordinator: EnableCloudCoordinatorProtocol) {
        self.coordinator = coordinator

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        itemsContinuation.yield([
            PageCellItem.pageHeader(
                headline: L10n.EnableCloud.title,
                subheadline: L10n.EnableCloud.subtitle
            ),
            PageCellItem.featureRow(
                systemImageName: "macbook.and.iphone",
                text: L10n.EnableCloud.Feature.sync
            ),
            PageCellItem.featureRow(
                systemImageName: "person.3.fill",
                text: L10n.EnableCloud.Feature.share
            ),
        ])

        (rightNavigationItems, rightNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        rightNavigationItemsContinuation.yield([
            PageNavigationItem.symbol(
                systemImageName: "xmark"
            ) { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.dismiss()
                }
            }
        ])
    }

    private func didTapCloseButton() {
        coordinator?.dismiss()
    }

    private func didTapLearnHowToEnable() {
        coordinator?.openLearnHowToEnable()
    }
}
