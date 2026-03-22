import Foundation

@MainActor
final class CloudMigrationViewModel: Sendable {

    struct Item: Sendable {
        let businessModel: CloudMigrationNoteBusinessModel
        let onAction: @MainActor @Sendable () -> Void
    }

    let items: AsyncStream<[Item]>
    private let itemsContinuation: AsyncStream<[Item]>.Continuation

    private weak var coordinator: CloudMigrationCoordinator?

    private(set) lazy var actions: [CallToActionStackView.ButtonConfiguration] = [
        .init(style: .primary, title: "Done", icon: nil, action: { [weak self] in
            self?.didTapDoneButton()
        }),
    ]

    init(coordinator: CloudMigrationCoordinator) {
        self.coordinator = coordinator

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [Item].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        itemsContinuation.yield(
            [
                Item(
                    businessModel: CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Project Brainstorm",
                        lastEditedDateString: "February 15 2026",
                        isCloudSynchronized: false
                    ),
                    onAction: { [weak self] in
                        self?.didTapItem(index: 0)
                    }
                ),
                Item(
                    businessModel: CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Sketch Ideas",
                        lastEditedDateString: "May 11 2023",
                        isCloudSynchronized: false
                    ),
                    onAction: {

                    }
                ),
                Item(
                    businessModel: CloudMigrationNoteBusinessModel(
                        previewImage: nil,
                        name: "Calculator Pro",
                        lastEditedDateString: "April 25 2021",
                        isCloudSynchronized: true
                    ),
                    onAction: {

                    }
                ),
            ]
        )
    }

    private func didTapItem(index: Int) {
        
    }

    private func didTapDoneButton() {
        coordinator?.dismiss()
    }
}
