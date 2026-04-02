/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

@preconcurrency import PencilKit

@MainActor
final class EditJotViewModel: Sendable {

    struct Drawing: Sendable {
        let value: PKDrawing
        let width: CGFloat
    }

    private(set) lazy var menuConfigurations = menuConfigurationFactory.make(
        onShare: { [weak self] format in
            Task { @MainActor [weak self] in
                self?.coordinator?.showShareJot(format: format)
            }
        },
        onRename: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                self.coordinator?.showRenameAlert(jotFileInfo: self.jotFileInfo)
            }
        },
        onDuplicate: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                self.didTapDuplicateJot(jotFileInfo: self.jotFileInfo)
            }
        },
        onDelete: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                self.coordinator?.openDeleteJot(jotFileInfo: self.jotFileInfo)
            }
        },
        onShowInFiles: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                self.coordinator?.showInFiles(jotFileInfo: self.jotFileInfo)
            }
        }
    )

    var title: String {
        jotFileInfo.name
    }

    let drawing: AsyncStream<Drawing>
    private let drawingContinuation: AsyncStream<Drawing>.Continuation

    let isEditing: AsyncStream<Bool?>
    private let isEditingContinuation: AsyncStream<Bool?>.Continuation

    let showsBackButton: AsyncStream<Bool>
    private let showsBackButtonContinuation: AsyncStream<Bool>.Continuation

    private var drawingUpdateTask: Task<Void, Never>?
    private let drawingUpdateContinuation: AsyncStream<PKDrawing>.Continuation

    private var loadingTask: Task<Void, Never>?

    private let jotFileInfo: JotFile.Info
    private let repository: EditJotRepositoryProtocol
    private weak var coordinator: EditJotCoordinator?
    private let menuConfigurationFactory: JotMenuConfigurationFactory

    init(
        jotFileInfo: JotFile.Info,
        repository: EditJotRepositoryProtocol,
        coordinator: EditJotCoordinator,
        menuConfigurationFactory: JotMenuConfigurationFactory
    ) {
        self.jotFileInfo = jotFileInfo
        self.coordinator = coordinator
        self.repository = repository
        self.menuConfigurationFactory = menuConfigurationFactory
        (isEditing, isEditingContinuation) = AsyncStream.makeStream(
            of: Bool?.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        (drawing, drawingContinuation) = AsyncStream.makeStream(
            of: Drawing.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        (showsBackButton, showsBackButtonContinuation) = AsyncStream.makeStream(
            of: Bool.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        #if targetEnvironment(macCatalyst)
        isEditingContinuation.yield(nil)
        #else
        isEditingContinuation.yield(false)
        #endif

        isEditingContinuation.yield(false)

        let (drawingUpdate, drawingUpdateContinuation) = AsyncStream.makeStream(
            of: PKDrawing.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        self.drawingUpdateContinuation = drawingUpdateContinuation

        drawingUpdateTask = Task.detached {
            for await drawing in drawingUpdate.dropFirst().debounce(for: 0.3) {
                do {
                    let jot = Jot.makeEmpty()
                    let jotFile = JotFile(
                        info: jotFileInfo,
                        jot: Jot(
                            version: jot.version,
                            drawing: drawing.dataRepresentation(),
                            width: jot.width
                        )
                    )
                    try repository.writeDrawing(jotFile: jotFile)
                } catch {
                    print(error)
                }
            }
        }
    }

    func didLoad() {
        showsBackButtonContinuation.yield(coordinator?.canGoBack() ?? false)

        if let jotFileVersions = repository.getConflictingVersions(jotFileInfo: jotFileInfo) {
            coordinator?.showJotConflictPage(
                jotFileInfo: jotFileInfo,
                jotFileVersions: jotFileVersions
            ) { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .keepAll:
                        self?.coordinator?.goBack()
                    case let .keep(jotFileInfo):
                        self?.coordinator?.openJot(jotFileInfo: jotFileInfo)
                    }
                }
            }
        } else {
            loadingTask = Task.detached { [weak self] in
                guard let self else {
                    return
                }
                do {
                    let (drawing, width) = try repository.readDrawing(jotFileInfo: jotFileInfo)
                    drawingContinuation.yield(Drawing(value: drawing, width: width))
                } catch {
                    print(error)
                }
            }
        }
    }

    func didTapToggleEditingButton(isEditing: Bool) {
        isEditingContinuation.yield(!isEditing)
    }

    func didChangeDrawing(_ drawing: PKDrawing) {
        drawingUpdateContinuation.yield(drawing)
    }

    func didTapBackButton() {
        if let jotFileVersions = repository.getConflictingVersions(jotFileInfo: jotFileInfo) {
            coordinator?.showJotConflictPage(
                jotFileInfo: jotFileInfo,
                jotFileVersions: jotFileVersions
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.coordinator?.goBack()
                }
            }
        } else {
            coordinator?.goBack()
        }
    }

    private func didTapDuplicateJot(jotFileInfo: JotFile.Info) {
        do {
            let duplicatedJotFileInfo = try repository.duplicate(jotFileInfo: jotFileInfo)
            coordinator?.openJot(jotFileInfo: duplicatedJotFileInfo)
        } catch {
            coordinator?.showInfoAlert(
                title: L10n.Jots.Duplicate.Error.generic(jotFileInfo.name),
                message: error.localizedDescription
            )
        }
    }

    deinit {
        drawingUpdateTask?.cancel()
    }
}
