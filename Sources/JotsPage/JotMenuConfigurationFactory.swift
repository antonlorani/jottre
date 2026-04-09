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

struct JotMenuConfigurations {

    private let makeProvider:
        @Sendable (_ popoverAnchorProvider: @MainActor @Sendable @escaping () -> PopoverAnchor?) ->
            [JotMenuConfiguration]

    init(
        makeProvider:
            @Sendable @escaping (_ popoverAnchorProvider: @MainActor @Sendable @escaping () -> PopoverAnchor?) ->
            [JotMenuConfiguration]
    ) {
        self.makeProvider = makeProvider
    }

    func make(popoverAnchorProvider: @MainActor @Sendable @escaping () -> PopoverAnchor?) -> [JotMenuConfiguration] {
        makeProvider(popoverAnchorProvider)
    }
}

struct JotMenuConfigurationFactory: Sendable {

    func make(
        onShare: @Sendable @escaping (ShareFormat, PopoverAnchor?) -> Void,
        onRename: @Sendable @escaping () -> Void,
        onDuplicate: @Sendable @escaping () -> Void,
        onDelete: @Sendable @escaping () -> Void,
        onShowInFiles: @Sendable @escaping () -> Void,
        onOpenInNewWindow: (@Sendable () -> Void)? = nil
    ) -> JotMenuConfigurations {
        JotMenuConfigurations { popoverAnchorProvider in
            var menuConfiguration = [JotMenuConfiguration]()

            if let onOpenInNewWindow {
                menuConfiguration.append(
                    .action(
                        JotMenuConfiguration.Action(
                            title: L10n.Jots.Menu.openInNewWindow,
                            systemImageName: "plus.app"
                        ) {
                            onOpenInNewWindow()
                        }
                    )
                )
            }

            menuConfiguration.append(contentsOf: [
                .action(
                    JotMenuConfiguration.Action(
                        title: L10n.Action.rename,
                        systemImageName: "pencil"
                    ) {
                        onRename()
                    }
                ),
                .action(
                    JotMenuConfiguration.Action(
                        title: L10n.Action.duplicate,
                        systemImageName: "plus.square.on.square"
                    ) {
                        onDuplicate()
                    }
                ),
                .action(
                    JotMenuConfiguration.Action(
                        title: L10n.Action.delete,
                        systemImageName: "trash",
                        isDestructive: true
                    ) {
                        onDelete()
                    }
                ),
                .action(
                    JotMenuConfiguration.Action(
                        title: {
                            #if targetEnvironment(macCatalyst)
                            L10n.Jots.Menu.revealInFinder
                            #else
                            L10n.Jots.Menu.revealInFiles
                            #endif
                        }(),
                        systemImageName: "folder"
                    ) {
                        onShowInFiles()
                    }
                ),
                .group(
                    JotMenuConfiguration.Group(
                        title: L10n.Action.share,
                        systemImageName: "square.and.arrow.up",
                        actions: [
                            JotMenuConfiguration.Action(
                                title: L10n.Share.Format.pdf,
                                systemImageName: "doc.fill"
                            ) {
                                onShare(.pdf, popoverAnchorProvider())
                            },
                            JotMenuConfiguration.Action(
                                title: L10n.Share.Format.jpg,
                                systemImageName: "photo.fill"
                            ) {
                                onShare(.jpg, popoverAnchorProvider())
                            },
                            JotMenuConfiguration.Action(
                                title: L10n.Share.Format.png,
                                systemImageName: "photo"
                            ) {
                                onShare(.png, popoverAnchorProvider())
                            },
                        ]
                    )
                ),
            ])

            return menuConfiguration
        }
    }
}
