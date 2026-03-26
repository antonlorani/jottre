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

import UIKit

@MainActor
final class NotesViewModel: PageViewModel {

    var title: String? {
        #if targetEnvironment(macCatalyst)
        nil
        #else
        L10n.App.title
        #endif
    }

    let leftNavigationItems: AsyncStream<[PageNavigationItem]>
    private let leftNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let rightNavigationItems: AsyncStream<[PageNavigationItem]>
    private let rightNavigationItemsContinuation: AsyncStream<[PageNavigationItem]>.Continuation

    let items: AsyncStream<[PageCellItem]>
    private let itemsContinuation: AsyncStream<[PageCellItem]>.Continuation

    let actions = [PageCallToActionView.ActionConfiguration]()

    private var notesTask: Task<Void, Never>?
    private weak var coordinator: NotesCoordinator?
    private let menuConfigurationFactory: NoteMenuConfigurationFactory

    init(
        coordinator: NotesCoordinator,
        repository: NotesRepositoryProtocol,
        menuConfigurationFactory: NoteMenuConfigurationFactory
    ) {
        self.coordinator = coordinator
        self.menuConfigurationFactory = menuConfigurationFactory

        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        (leftNavigationItems, leftNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        leftNavigationItemsContinuation.yield([
            .symbol(
                systemImageName: "gear",
            ) { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.openSettings()
                }
            },
            .symbol(
                systemImageName: "icloud.slash",
            ) { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.openEnableCloudPage()
                }
            },
        ])

        (rightNavigationItems, rightNavigationItemsContinuation) = AsyncStream.makeStream(
            of: [PageNavigationItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )
        rightNavigationItemsContinuation.yield([
            .text(
                title: L10n.Action.create
            ) { [weak coordinator] in
                Task { @MainActor in
                    coordinator?.openCreateNote()
                }
            }
        ])

        notesTask = Task { [weak self] in
            do {
                for try await jotFiles in try repository.getJotFiles() {
                    self?.handleJots(jotFiles: jotFiles)
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleJots(jotFiles: [JotFileBusinessModel]) {
        guard !jotFiles.isEmpty else {
            itemsContinuation.yield([
                .notesEmptyState(title: "A blank page full of possibilities. Go ahead, jot something insanely great!")
            ])
            return
        }
        itemsContinuation.yield(
            jotFiles.map { jotFile in
                let note = NoteBusinessModel(
                    previewImage: nil,
                    name: jotFile.name,
                    lastEditedDateString: "",
                    isCloudSynchronized: false
                )
                return .note(
                    note: note,
                    infoText: nil,
                    noteMenuConfigurations: menuConfigurationFactory.make(
                        onShare: { [weak coordinator] format in
                            Task { @MainActor in
                                coordinator?.showShareNote(format: format)
                            }
                        },
                        onRename: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.showRenameAlert()
                            }
                        },
                        onDuplicate: {
                            /* no-op */
                        },
                        onDelete: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.showDeleteConfirmationAlert()
                            }
                        },
                        onShowInFiles: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.showInFiles()
                            }
                        }
                    ),
                    sizing: .adaptiveGrid(maxColumns: 8, minItemWidth: 205, itemHeight: 216),
                    onAction: { [weak coordinator] in
                        Task { @MainActor in
                            coordinator?.openJot(jotFile)
                        }
                    }
                )
            }
        )
    }

    deinit {
        notesTask?.cancel()
    }
}
