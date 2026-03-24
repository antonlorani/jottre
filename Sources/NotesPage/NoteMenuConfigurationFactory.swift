struct NoteMenuConfigurationFactory: Sendable {

    func make(
        onShare: @Sendable @escaping (ShareFormat) -> Void,
        onRename: @Sendable @escaping () -> Void,
        onDuplicate: @Sendable @escaping () -> Void,
        onDelete: @Sendable @escaping () -> Void,
        onShowInFiles: @Sendable @escaping () -> Void
    ) -> [NoteMenuConfiguration] {
        [
            .group(
                NoteMenuConfiguration.Group(
                    title: L10n.Action.share,
                    systemImageName: "square.and.arrow.up",
                    actions: [
                        NoteMenuConfiguration.Action(
                            title: L10n.Share.Format.pdf,
                            systemImageName: "doc.fill"
                        ) {
                            onShare(.pdf)
                        },
                        NoteMenuConfiguration.Action(
                            title: L10n.Share.Format.jpg,
                            systemImageName: "photo.fill"
                        ) {
                            onShare(.jpg)
                        },
                        NoteMenuConfiguration.Action(
                            title: L10n.Share.Format.png,
                            systemImageName: "photo"
                        ) {
                            onShare(.png)
                        }
                    ]
                )
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: L10n.Action.rename,
                    systemImageName: "pencil"
                ) {
                    onRename()
                }
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: L10n.Action.duplicate,
                    systemImageName: "plus.square.on.square"
                ) {
                    onDuplicate()
                }
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: L10n.Action.delete,
                    systemImageName: "trash",
                    isDestructive: true
                ) {
                    onDelete()
                }
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: {
#if targetEnvironment(macCatalyst)
                        L10n.Notes.Menu.showInFinder
#else
                        L10n.Notes.Menu.showInFiles
#endif
                    }(),
                    systemImageName: "folder"
                ) {
                    onShowInFiles()
                }
            )
        ]
    }
}
