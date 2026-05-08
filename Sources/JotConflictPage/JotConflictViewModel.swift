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

import Foundation

@MainActor
final class JotConflictViewModel: PageViewModel, Sendable {

    private enum Constants {

        static func character(offset: Int) -> String {
            UnicodeScalar(65 + offset)?.description ?? String()
        }
    }

    private(set) lazy var items: AsyncStream<[PageCellItem]> = AsyncStream<[PageCellItem]>(
        [PageCellItem].self,
        bufferingPolicy: .bufferingNewest(1)
    ) { continuation in
        var pageCellItems = [
            PageCellItem.pageHeader(
                headline: L10n.JotConflict.title,
                subheadline: jotFileVersions.first.map { L10n.JotConflict.subtitle($0.info.name) } ?? String()
            )
        ]
        pageCellItems.append(
            contentsOf:
                jotFileVersions
                .enumerated()
                .map { offset, jotFileVersion in
                    PageCellItem.jotConflict(
                        jotConflict: JotConflictBusinessModel(
                            name: L10n.JotConflict.versionName(Constants.character(offset: offset)),
                            jotFileInfo: jotFileInfo,
                            jotFileVersion: jotFileVersion
                        ),
                        sizing: .equalSplit(
                            perRow: jotFileVersions.count,
                            itemHeight: 200
                        ),
                        repository: repository
                    )
                }
        )
        continuation.yield(pageCellItems)
        continuation.finish()
    }

    private(set) lazy var actions =
        jotFileVersions
        .enumerated()
        .map { (offset, jotFileVersion) in
            PageCallToActionView.ActionConfiguration(
                style: .primary,
                title: L10n.JotConflict.Action.keepVersion(Constants.character(offset: offset)),
                icon: nil
            ) { [weak self] in
                self?.didTapKeepVersion(jotFileVersion: jotFileVersion)
            }
        } + [
            PageCallToActionView.ActionConfiguration(
                style: .secondary,
                title: L10n.JotConflict.Action.keepAll,
                icon: nil
            ) { [weak self] in
                self?.didTapKeepAll()
            }
        ]

    private let jotFileInfo: JotFile.Info
    private let jotFileVersions: [JotFileVersion]
    private let repository: JotConflictRepositoryProtocol
    private weak var coordinator: JotConflictCoordinatorProtocol?
    private let onResult: @Sendable (_ result: JotConflictResult) -> Void

    init(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        repository: JotConflictRepositoryProtocol,
        coordinator: JotConflictCoordinatorProtocol,
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) {
        assert(jotFileVersions.count >= 1, "Resolving a version conflict between less than two files is not logical.")
        self.jotFileInfo = jotFileInfo
        self.jotFileVersions =
            [
                JotFileVersion(
                    localizedNameOfSavingComputer: L10n.JotConflict.deviceLabel,
                    info: jotFileInfo
                )
            ] + jotFileVersions
        self.repository = repository
        self.coordinator = coordinator
        self.onResult = onResult
    }

    private func didTapKeepVersion(jotFileVersion: JotFileVersion) {
        do {
            try repository.resolveVersionConflicts(
                jotFileInfo: jotFileInfo,
                resolvedVersions: [jotFileVersion]
            )
            coordinator?.dismiss(completion: { [weak self] in
                guard let self else {
                    return
                }
                onResult(.keep(jotFileInfo))
            })
        } catch {
            coordinator?.showInfoAlert(
                title: L10n.JotConflict.Error.generic,
                message: error.localizedDescription
            )
        }
    }

    private func didTapKeepAll() {
        do {
            try repository.resolveVersionConflicts(
                jotFileInfo: jotFileInfo,
                resolvedVersions: jotFileVersions
            )
            coordinator?.dismiss(completion: { [weak self] in
                self?.onResult(.keepAll)
            })
        } catch {
            coordinator?.showInfoAlert(
                title: L10n.JotConflict.Error.generic,
                message: error.localizedDescription
            )
        }
    }
}
