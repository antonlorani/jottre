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
final class JotsViewModel: PageViewModel {

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

    private var jotsTask: Task<Void, Never>?

    private weak var coordinator: JotsCoordinator?

    let repository: JotsRepositoryProtocol
    private let menuConfigurationFactory: JotMenuConfigurationFactory

    init(
        coordinator: JotsCoordinator,
        repository: JotsRepositoryProtocol,
        menuConfigurationFactory: JotMenuConfigurationFactory
    ) {
        self.coordinator = coordinator
        self.repository = repository
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
                    coordinator?.openCreateJot()
                }
            }
        ])

        jotsTask = Task { [weak self] in
            do {
                for try await jotFileInfos in repository.getJotFiles() {
                    self?.handleJots(jotFileInfos: jotFileInfos)
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleJots(jotFileInfos: [JotFile.Info]) {
        guard !jotFileInfos.isEmpty else {
            itemsContinuation.yield([
                .jotsEmptyState(title: "A blank page full of possibilities. Go ahead, jot something insanely great!")
            ])
            return
        }
        itemsContinuation.yield(
            jotFileInfos.map { jotFileInfo in
                let jot = JotBusinessModel(
                    previewImage: nil,
                    name: jotFileInfo.name
                )
                return .jot(
                    jot: jot,
                    infoText: nil,
                    jotMenuConfigurations: menuConfigurationFactory.make(
                        onShare: { [weak coordinator] format in
                            Task { @MainActor in
                                coordinator?.showShareJot(format: format)
                            }
                        },
                        onRename: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.showRenameAlert(jotFileInfo: jotFileInfo)
                            }
                        },
                        onDuplicate: { [weak self] in
                            Task { @MainActor in
                                self?.didTapDuplicateJot(jotFileInfo: jotFileInfo)
                            }
                        },
                        onDelete: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.openDeleteJot(jotFileInfo: jotFileInfo)
                            }
                        },
                        onShowInFiles: { [weak coordinator] in
                            Task { @MainActor in
                                coordinator?.showInFiles(jotFileInfo: jotFileInfo)
                            }
                        }
                    ),
                    sizing: .adaptiveGrid(maxColumns: 8, minItemWidth: 205, itemHeight: 216),
                    onAction: { [weak coordinator] in
                        Task { @MainActor in
                            coordinator?.openJot(jotFileInfo: jotFileInfo)
                        }
                    }
                )
            }
        )
    }

    private func didTapDuplicateJot(jotFileInfo: JotFile.Info) {
        do {
            _ = try repository.duplicate(jotFileInfo: jotFileInfo)
        } catch {
            coordinator?.showInfoAlert(
                title: L10n.Jots.Duplicate.Error.generic(jotFileInfo.name),
                message: error.localizedDescription
            )
        }
    }

    deinit {
        jotsTask?.cancel()
    }
}
