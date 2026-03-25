import UIKit

@MainActor
final class EnableCloudViewModel: PageViewModel, Sendable {

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private weak var coordinator: EnableCloudCoordinator?

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.EnableCloud.Action.learnHowToEnable,
            icon: "arrow.up.forward"
        ) { [weak self] in
            self?.didTapLearnHowToEnable()
        },
    ]

    init(coordinator: EnableCloudCoordinator) {
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
            )
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
