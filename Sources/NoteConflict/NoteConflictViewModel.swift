import Foundation

@MainActor
final class NoteConflictViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageItem]>
    private let _itemsContinuation: AsyncStream<[PageItem]>.Continuation

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: "Keep Version A",
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionA()
        },
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: "Keep Version B",
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionB()
        },
        PageCallToActionView.ActionConfiguration(
            style: .secondary,
            title: "Keep Both",
            icon: nil
        ) { [weak self] in
            self?.didTapKeepBoth()
        },
    ]

    private weak var coordinator: NoteConflictCoordinator?

    init(coordinator: NoteConflictCoordinator) {
        self.coordinator = coordinator

        (items, _itemsContinuation) = AsyncStream.makeStream(
            of: [PageItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        _itemsContinuation.yield([
            PageItem(
                content: .pageHeader(
                    PageHeaderBusinessModel(
                        headline: "Version Conflict",
                        subheadline: #""Sketch Final" was edited on two devices at the same time. Choose a version to keep."#
                    )
                ),
                sizing: .fullWidth
            ),
            PageItem(
                content: .note(
                    NoteBusinessModel(previewImage: nil, name: "Version A"),
                    infoText: "This Device - now",
                    onAction: {}
                ),
                sizing: .equalSplit(perRow: 2, height: 250)
            ),
            PageItem(
                content: .note(
                    NoteBusinessModel(previewImage: nil, name: "Version B"),
                    infoText: "iPhone - 3:08 pm",
                    onAction: {}
                ),
                sizing: .equalSplit(perRow: 2, height: 250)
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
