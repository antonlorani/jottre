import Foundation

@MainActor
final class NoteConflictViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageCellItem]>
    private let _itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.NoteConflict.Action.keepVersionA,
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionA()
        },
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: L10n.NoteConflict.Action.keepVersionB,
            icon: nil
        ) { [weak self] in
            self?.didTapKeepVersionB()
        },
        PageCallToActionView.ActionConfiguration(
            style: .secondary,
            title: L10n.NoteConflict.Action.keepBoth,
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
                headline: L10n.NoteConflict.title,
                subheadline: L10n.NoteConflict.subtitle("Sketch Final")
            ),
            .note(
                note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Version A",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "This Device - now",
                noteMenuConfigurations: [],
                sizing: .equalSplit(perRow: 2, itemHeight: 250),
                onAction: { /* no-op */ }
            ),
            .note(
                note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Version B",
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                ),
                infoText: "iPhone - 3:08 pm",
                noteMenuConfigurations: [],
                sizing: .equalSplit(perRow: 2, itemHeight: 250),
                onAction: { /* no-op */ }
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
