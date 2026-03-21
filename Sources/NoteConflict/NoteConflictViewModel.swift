import Foundation

@MainActor
final class NoteConflictViewModel: Sendable {

    struct NoteItem: Sendable {
        let note: NoteBusinessModel
        let infoText: String?
    }

    struct ActionItem: Sendable {
        enum Style: Sendable {
            case primary
            case secondary
        }
        let title: String
        let style: Style
        let onTap: @MainActor @Sendable () -> Void
    }

    let headline: String
    let subheadline: String

    private(set) lazy var notes: [NoteItem] = [
        NoteItem(
            note: NoteBusinessModel(previewImage: nil, name: "Version A"),
            infoText: "This Device - now"
        ),
        NoteItem(
            note: NoteBusinessModel(previewImage: nil, name: "Version B"),
            infoText: "iPhone - 3:08 pm"
        ),
    ]

    private(set) lazy var actions: [ActionItem] = [
        ActionItem(title: "Keep Version A", style: .primary, onTap: { [weak self] in
            self?.didTapKeepVersionA()
        }),
        ActionItem(title: "Keep Version B", style: .primary, onTap: { [weak self] in
            self?.didTapKeepVersionB()
        }),
        ActionItem(title: "Keep Both", style: .secondary, onTap: { [weak self] in
            self?.didTapKeepBoth()
        }),
    ]

    private weak var coordinator: NoteConflictCoordinator?

    init(coordinator: NoteConflictCoordinator) {
        self.coordinator = coordinator
        headline = "Version Conflict"
        subheadline = "\"Sketch Final\" was edited on two devices at the same time. Choose a version to keep."
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
