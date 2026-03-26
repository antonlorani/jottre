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

@MainActor
final class EditJotViewModel: Sendable {

    private(set) lazy var menuConfigurations = menuConfigurationFactory.make(
        onShare: { [weak self] format in
            Task { @MainActor in
                self?.coordinator?.showShareJot(format: format)
            }
        },
        onRename: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showRenameAlert()
            }
        },
        onDuplicate: { [weak self] in
            Task { @MainActor in
                self?.didTapDuplicateJot()
            }
        },
        onDelete: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showDeleteConfirmationAlert()
            }
        },
        onShowInFiles: { [weak self] in
            Task { @MainActor in
                self?.coordinator?.showInFiles()
            }
        }
    )

    let isEditing: AsyncStream<Bool?>
    private let isEditingContinuation: AsyncStream<Bool?>.Continuation

    private weak var coordinator: EditJotCoordinator?
    private let menuConfigurationFactory: JotMenuConfigurationFactory

    init(
        coordinator: EditJotCoordinator,
        menuConfigurationFactory: JotMenuConfigurationFactory
    ) {
        self.coordinator = coordinator
        self.menuConfigurationFactory = menuConfigurationFactory
        (isEditing, isEditingContinuation) = AsyncStream.makeStream(
            of: Bool?.self,
            bufferingPolicy: .bufferingNewest(1)
        )

        #if targetEnvironment(macCatalyst)
        isEditingContinuation.yield(nil)
        #else
        isEditingContinuation.yield(false)
        #endif
    }

    func didTapToggleEditingButton(isEditing: Bool) {
        isEditingContinuation.yield(!isEditing)
    }

    private func didTapDuplicateJot() {

    }
}
