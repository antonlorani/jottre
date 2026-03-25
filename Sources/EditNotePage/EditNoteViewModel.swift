@MainActor
final class EditNoteViewModel: Sendable {

    private(set) lazy var menuConfigurations = menuConfigurationFactory.make(
        onShare: { [weak self] format in
            Task { @MainActor in
                self?.coordinator?.showShareNote(format: format)
            }
        },
        onRename: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showRenameAlert()
            }
        },
        onDuplicate: { [weak self] in
            Task { @MainActor in
                self?.didTapDuplicateNote()
            }
        },
        onDelete: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showDeleteConfirmationAlert()
            }
        },
        onShowInFiles: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showInFiles()
            }
        }
    )

    let isEditing: AsyncStream<Bool?>
    private let isEditingContinuation: AsyncStream<Bool?>.Continuation

    private weak var coordinator: EditNoteCoordinator?
    private let menuConfigurationFactory: NoteMenuConfigurationFactory

    init(
        coordinator: EditNoteCoordinator,
        menuConfigurationFactory: NoteMenuConfigurationFactory
    ) {
        self.coordinator = coordinator
        self.menuConfigurationFactory = menuConfigurationFactory
        (isEditing, isEditingContinuation) = AsyncStream.makeStream(
            of: Bool?.self,
            bufferingPolicy: .bufferingNewest(1)
        )

#if targetEnvironment(macCatalyst)
        isEditingContinuation.yield(nil)
#else
        isEditingContinuation.yield(false)
#endif
    }

    func didTapToggleEditingButton(isEditing: Bool) {
        isEditingContinuation.yield(!isEditing)
    }

    private func didTapDuplicateNote() {

    }
}
