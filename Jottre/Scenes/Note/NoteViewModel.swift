import Foundation
import Combine

final class NoteViewModel {
    private weak var coordinator: NoteCoordinator?

    private static let queue = DispatchQueue(label: "com.jottre.note")

    private lazy var note = Just(url)
        .receive(on: Self.queue)
        .compactMap { [weak self] url in
            self?.noteDataSource.getNote(url: url)
        }
        .eraseToAnyPublisher()

    lazy var navigationTitle = note
        .map(\.name)
        .eraseToAnyPublisher()

    lazy var drawing = note
        .map { $0.asNote() }
        .map(\.drawing)
        .eraseToAnyPublisher()

    private let url: URL
    private let noteDataSource: NoteFileDataSource

    init(
        noteDataSource: NoteFileDataSource,
        coordinator: NoteCoordinator,
        url: URL
    ) {
        self.noteDataSource = noteDataSource
        self.coordinator = coordinator
        self.url = url
    }

    func didClickExportNote() {
        weak var `self` = self
        coordinator?.showExportNoteAlert(
            onPDFSelected: {
                
            },
            onJPGSelected: {

            },
            onPNGSelected: {

            }
        )
    }
}
