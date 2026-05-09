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

@testable import Jottre

@MainActor
final class CreateJotCoordinatorFactoryMock: CreateJotCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ navigation: Navigation) -> Coordinator

    init(
        makeProvider: @MainActor @escaping (_ navigation: Navigation) -> Coordinator = { _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(navigation: Navigation) -> Coordinator {
        makeProvider(navigation)
    }
}

@MainActor
final class DeleteJotCoordinatorFactoryMock: DeleteJotCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ jotFileInfo: JotFile.Info, _ navigation: Navigation) -> Coordinator

    init(
        makeProvider:
            @MainActor @escaping (_ jotFileInfo: JotFile.Info, _ navigation: Navigation) -> Coordinator = { _, _ in
                CoordinatorMock()
            }
    ) {
        self.makeProvider = makeProvider
    }

    func make(jotFileInfo: JotFile.Info, navigation: Navigation) -> Coordinator {
        makeProvider(jotFileInfo, navigation)
    }
}

@MainActor
final class RenameJotCoordinatorFactoryMock: RenameJotCoordinatorFactoryProtocol {

    private let makeProvider:
        @MainActor (
            _ jotFileInfo: JotFile.Info,
            _ navigation: Navigation,
            _ onRename: @Sendable (_ renameJotFileInfo: JotFile.Info) -> Void
        ) -> Coordinator

    init(
        makeProvider:
            @MainActor @escaping (
                _ jotFileInfo: JotFile.Info,
                _ navigation: Navigation,
                _ onRename: @Sendable (_ renameJotFileInfo: JotFile.Info) -> Void
            ) -> Coordinator = { _, _, _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(
        jotFileInfo: JotFile.Info,
        navigation: Navigation,
        onRename: @Sendable @escaping (_ renameJotFileInfo: JotFile.Info) -> Void
    ) -> Coordinator {
        makeProvider(jotFileInfo, navigation, onRename)
    }
}

@MainActor
final class ShareJotCoordinatorFactoryMock: ShareJotCoordinatorFactoryProtocol {

    private let makeProvider:
        @MainActor (
            _ jotFileInfo: JotFile.Info,
            _ format: ShareFormat,
            _ navigation: Navigation,
            _ configurePopoverAnchor: PopoverAnchor?
        ) -> Coordinator

    init(
        makeProvider:
            @MainActor @escaping (
                _ jotFileInfo: JotFile.Info,
                _ format: ShareFormat,
                _ navigation: Navigation,
                _ configurePopoverAnchor: PopoverAnchor?
            ) -> Coordinator = { _, _, _, _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(
        jotFileInfo: JotFile.Info,
        format: ShareFormat,
        navigation: Navigation,
        configurePopoverAnchor: PopoverAnchor?
    ) -> Coordinator {
        makeProvider(jotFileInfo, format, navigation, configurePopoverAnchor)
    }
}

@MainActor
final class RevealFileCoordinatorFactoryMock: RevealFileCoordinatorFactoryProtocol {

    private let makeProvider: @MainActor (_ jotFileInfo: JotFile.Info, _ navigation: Navigation) -> Coordinator

    init(
        makeProvider:
            @MainActor @escaping (_ jotFileInfo: JotFile.Info, _ navigation: Navigation) -> Coordinator = { _, _ in
                CoordinatorMock()
            }
    ) {
        self.makeProvider = makeProvider
    }

    func make(jotFileInfo: JotFile.Info, navigation: Navigation) -> Coordinator {
        makeProvider(jotFileInfo, navigation)
    }
}

@MainActor
final class JotConflictCoordinatorFactoryMock: JotConflictCoordinatorFactoryProtocol {

    private let makeProvider:
        @MainActor (
            _ jotFileInfo: JotFile.Info,
            _ jotFileVersions: [JotFileVersion],
            _ navigation: Navigation,
            _ onResult: @Sendable (_ result: JotConflictResult) -> Void
        ) -> Coordinator

    init(
        makeProvider:
            @MainActor @escaping (
                _ jotFileInfo: JotFile.Info,
                _ jotFileVersions: [JotFileVersion],
                _ navigation: Navigation,
                _ onResult: @Sendable (_ result: JotConflictResult) -> Void
            ) -> Coordinator = { _, _, _, _ in CoordinatorMock() }
    ) {
        self.makeProvider = makeProvider
    }

    func make(
        jotFileInfo: JotFile.Info,
        jotFileVersions: [JotFileVersion],
        navigation: Navigation,
        onResult: @Sendable @escaping (_ result: JotConflictResult) -> Void
    ) -> Coordinator {
        makeProvider(jotFileInfo, jotFileVersions, navigation, onResult)
    }
}
