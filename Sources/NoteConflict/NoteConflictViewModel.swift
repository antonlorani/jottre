import Foundation

@MainActor
final class NoteConflictViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageCellItem]>
    private let _itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

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
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        _itemsContinuation.yield([
            .pageHeader(
                headline: "Version Conflict",
                subheadline: #""Sketch Final" was edited on two devices at the same time. Choose a version to keep."#
            ),
            .note(
                note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Version A",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "This Device - now",
                sizing: .equalSplit(perRow: 2, itemHeight: 250)
            ),
            .note(
                note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Version B",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "iPhone - 3:08 pm",
                sizing: .equalSplit(perRow: 2, itemHeight: 250)
            )
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
