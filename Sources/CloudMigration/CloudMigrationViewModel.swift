import Foundation

@MainActor
final class CloudMigrationViewModel: PageViewModel, Sendable {

    let items: AsyncStream<[PageItem]>
    private let _itemsContinuation: AsyncStream<[PageItem]>.Continuation

    private weak var coordinator: CloudMigrationCoordinator?

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: "Done",
            icon: nil
        ) { [weak self] in
            self?.didTapDoneButton()
        }
    ]

    init(coordinator: CloudMigrationCoordinator) {
        self.coordinator = coordinator

        (items, _itemsContinuation) = AsyncStream.makeStream(
            of: [PageItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        _itemsContinuation.yield([
            PageItem(
                content: .pageHeader(
                    PageHeaderBusinessModel(
                        headline: "iCloud is ready",
                        subheadline: "Your Jots can now sync across all your devices. Choose which ones to bring along."
                    )
                ),
                sizing: .fullWidth
            ),
            PageItem(
                content: .migrationNote(
                    CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Project Brainstorm",
                        lastEditedDateString: "February 15 2026",
                        isCloudSynchronized: false
                    ),
                    onAction: { [weak self] in
                        self?.didTapItem(index: 0)
                    }
                ),
                sizing: .adaptiveGrid(maxColumns: 2, height: 68)
            ),
            PageItem(
                content: .migrationNote(
                    CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Sketch Ideas",
                        lastEditedDateString: "May 11 2023",
                        isCloudSynchronized: false
                    ),
                    onAction: {}
                ),
                sizing: .adaptiveGrid(maxColumns: 2, height: 68)
            ),
            PageItem(
                content: .migrationNote(
                    CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Calculator Pro",
                        lastEditedDateString: "April 25 2021",
                        isCloudSynchronized: true
                    ),
                    onAction: {}
                ),
                sizing: .adaptiveGrid(maxColumns: 2, height: 68)
            ),
        ])
    }

    private func didTapItem(index: Int) {}

    private func didTapDoneButton() {
        coordinator?.dismiss()
    }
}
