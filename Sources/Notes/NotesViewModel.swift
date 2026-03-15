@MainActor
final class NotesViewModel: Sendable {

    struct Item {
        let note: NoteBusinessModel
        let onAction: () -> Void
    }

    let items: AsyncStream<[Item]>
    private let itemsContinuation: AsyncStream<[Item]>.Continuation

    private weak var coordinator: NotesCoordinator?

    init(coordinator: NotesCoordinator) {
        self.coordinator = coordinator

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [Item].self,
            bufferingPolicy: .bufferingOldest(1)
        )
        itemsContinuation.yield([
            Item(
                note: NoteBusinessModel(
                    previewImage: nil,
                    name: "Hello, world!"
                ),
                onAction: { [weak self] in
                    self?.coordinator?.openNote(NoteBusinessModel(
                        previewImage: nil,
                        name: "Hello, world!"
                    ))
                }
            )
        ])
    }

    func didTapSettingsButton() {
        coordinator?.openSettings()
    }

    func didTapCreateNoteButton() {
        coordinator?.openCreateNote()
    }
}
