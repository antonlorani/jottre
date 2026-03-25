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

    init(
        coordinator: NotesCoordinator,
        menuConfigurationFactory: NoteMenuConfigurationFactory
    ) {
        (items, itemsContinuation) = AsyncStream.makeStream(
            of: [PageCellItem].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        let notes = [
            NoteBusinessModel(
                previewImage: nil,
                name: "Calculator Pro",
                lastEditedDateString: "",
                isCloudSynchronized: false
            ),
            NoteBusinessModel(
                previewImage: nil,
                name: "Project Sketch",
                lastEditedDateString: "",
                isCloudSynchronized: false
            )
        ]

        itemsContinuation.yield(notes.map { note in
            PageCellItem.note(
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
                        coordinator?.openNote(note)
                    }
                }
            )
        })
//        itemsContinuation.yield([
//            .notesEmptyState(title: "A blank page full of possibilities. Go ahead, jot something insanely great!")
//        ])

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
            }
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
    }
}
