import Foundation

@MainActor
final class NoteConflictViewModel: Sendable {

    struct NoteItem: Sendable {
        let note: NoteBusinessModel
        let infoText: String?
    }

    let pageHeaderConfiguration: PageHeaderView.Configuration

    private(set) lazy var notes = [
        NoteItem(
            note: NoteBusinessModel(previewImage: nil, name: "Version A"),
            infoText: "This Device - now"
        ),
        NoteItem(
            note: NoteBusinessModel(previewImage: nil, name: "Version B"),
            infoText: "iPhone - 3:08 pm"
        ),
    ]

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: "Keep Version A",
            icon: nil)
        { [weak self] in
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
        pageHeaderConfiguration = PageHeaderView.Configuration(
            headline: "Version Conflict",
            subheadline: #""Sketch Final" was edited on two devices at the same time. Choose a version to keep."#
        )
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
