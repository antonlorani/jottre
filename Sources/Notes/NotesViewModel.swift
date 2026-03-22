@MainActor
final class NotesViewModel: Sendable {

    enum State {
        struct Item {
            let note: NoteBusinessModel
            let menuConfigurations: [NoteMenuConfiguration]
            let onAction: () -> Void
        }

        case filled(items: [Item])
        case empty(title: String)
    }

    let shouldShowEnableCloudButton = true

    let state: AsyncStream<State>
    private let stateContinuation: AsyncStream<State>.Continuation

    private weak var coordinator: NotesCoordinator?

    init(
        coordinator: NotesCoordinator,
        menuConfigurationFactory: NoteMenuConfigurationFactory
    ) {
        self.coordinator = coordinator

        (state, stateContinuation) = AsyncStream.makeStream(
            of: State.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        stateContinuation.yield(.empty(title: "A blank page full of possibilities. Go ahead, jot something insanely great!"))
        stateContinuation.yield(
            .filled(
                items: [
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    ),
                    State.Item(
                        note: NoteBusinessModel(
                            previewImage: nil,
                            name: "Hello, world!"
                        ),
                        menuConfigurations: menuConfigurationFactory.make(
                            onShare: { _ in },
                            onRename: {},
                            onDuplicate: {},
                            onDelete: {},
                            onShowInFiles: {}
                        ),
                        onAction: { [weak self] in
                            self?.coordinator?.openNote(NoteBusinessModel(
                                previewImage: nil,
                                name: "Hello, world!"
                            ))
                        }
                    )
                ]
            )
        )
    }

    func didTapSettingsButton() {
        coordinator?.openSettings()
    }

    func didTapCreateNoteButton() {
        coordinator?.openCreateNote()
    }

    func didTapEnableCloudButton() {
        coordinator?.openEnableCloudPage()
    }
}
