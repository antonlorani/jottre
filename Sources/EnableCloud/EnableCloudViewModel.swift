import UIKit

@MainActor
final class EnableCloudViewModel: PageViewModel, Sendable {

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageItem]>
    private let itemsContinuation: AsyncStream<[PageItem]>.Continuation

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
            of: [PageItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        itemsContinuation.yield([
            PageItem(
                content: .pageHeader(
                    PageHeaderBusinessModel(
                        headline: "Enable iCloud",
                        subheadline: "It looks like iCloud is disabled on this device. Turn on iCloud to get the most out of Jottre."
                    )
                ),
                sizing: .fullWidth
            ),
            PageItem(
                content: .featureRow(
                    FeatureRowBusinessModel(
                        systemImageName: "macbook.and.iphone",
                        text: "Synchronize jots across all your Apple devices"
                    )
                ),
                sizing: .fullWidth
            ),
            PageItem(
                content: .featureRow(
                    FeatureRowBusinessModel(
                        systemImageName: "person.3.fill",
                        text: "Share jots with others"
                    )
                ),
                sizing: .fullWidth
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
