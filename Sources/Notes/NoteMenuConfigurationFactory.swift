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
                    title: "Share",
                    systemImageName: "square.and.arrow.up",
                    actions: [
                        NoteMenuConfiguration.Action(
                            title: "PDF",
                            systemImageName: "doc.fill"
                        ) {
                            onShare(.pdf)
                        },
                        NoteMenuConfiguration.Action(
                            title: "JPG",
                            systemImageName: "photo.fill"
                        ) {
                            onShare(.jpg)
                        },
                        NoteMenuConfiguration.Action(
                            title: "PNG",
                            systemImageName: "photo"
                        ) {
                            onShare(.png)
                        }
                    ]
                )
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: "Rename",
                    systemImageName: "pencil"
                ) {
                    onRename()
                }
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: "Duplicate",
                    systemImageName: "plus.square.on.square"
                ) {
                    onDuplicate()
                }
            ),
            .action(
                NoteMenuConfiguration.Action(
                    title: "Delete",
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
                        "Show in Finder"
#else
                        "Show in Files"
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
