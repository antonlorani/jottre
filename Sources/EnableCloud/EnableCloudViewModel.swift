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
            title: "Learn How To Enable",
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
                headline: "Enable iCloud",
                subheadline: "It looks like iCloud is disabled on this device. Turn on iCloud to get the most out of Jottre."
            ),
            PageCellItem.featureRow(
                systemImageName: "macbook.and.iphone",
                text: "Synchronize jots across all your Apple devices"
            ),
            PageCellItem.featureRow(
                systemImageName: "person.3.fill",
                text: "Share jots with others"
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
