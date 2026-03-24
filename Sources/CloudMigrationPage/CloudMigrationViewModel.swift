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
                .cloudMigrationNote(note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Project Brainstorm",
                    lastEditedDateString: "February 15 2026",
                    isCloudSynchronized: false
                )),
                .cloudMigrationNote(note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Sketch Ideas",
                    lastEditedDateString: "May 11 2023",
                    isCloudSynchronized: false
                )),
                .cloudMigrationNote(note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Calculator Pro",
                    lastEditedDateString: "April 25 2021",
                    isCloudSynchronized: true
                ))
            ]
        )
    }

    private func didTapItem(index: Int) {}

    private func didTapDoneButton() {
        coordinator?.dismiss()
    }
}
