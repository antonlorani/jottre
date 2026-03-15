@MainActor
final class NotesViewModel: Sendable {

    enum State {
        struct Item {
            let note: NoteBusinessModel
            let onAction: () -> Void
        }

        case filled(items: [Item])
        case empty(title: String)
    }

    let state: AsyncStream<State>
    private let stateContinuation: AsyncStream<State>.Continuation

    private weak var coordinator: NotesCoordinator?

    init(coordinator: NotesCoordinator) {
        self.coordinator = coordinator

        (state, stateContinuation) = AsyncStream.makeStream(
            of: State.self,
            bufferingPolicy: .bufferingOldest(1)
        )
        stateContinuation.yield(.empty(title: "A blank page full of possibilities. Go ahead, jot something insanely great!"))
        //         .filled(
        //             [
        //                 Item(
        //                     note: NoteBusinessModel(
        //                         previewImage: nil,
        //                         name: "Hello, world!"
        //                     ),
        //                     onAction: { [weak self] in
        //                         self?.coordinator?.openNote(NoteBusinessModel(
        //                             previewImage: nil,
        //                             name: "Hello, world!"
        //                         ))
        //                     }
        //                 )
        //             ]
        //          )
    }

    func didTapSettingsButton() {
        coordinator?.openSettings()
    }

    func didTapCreateNoteButton() {
        coordinator?.openCreateNote()
    }
}
