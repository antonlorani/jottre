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

final class JotCellViewModel: PageCellViewModel {

    let name: String
    let jotMenuConfigurations: [JotMenuConfiguration]
    let onAction: @Sendable () -> Void

    private var previewImageContinuation: AsyncStream<UIImage?>.Continuation?
    private var previewImageTask: Task<Void, Never>?

    private let jot: JotBusinessModel
    private let repository: JotsRepositoryProtocol

    init(
        jot: JotBusinessModel,
        jotMenuConfigurations: [JotMenuConfiguration],
        repository: JotsRepositoryProtocol,
        onAction: @Sendable @escaping () -> Void
    ) {
        self.name = jot.name
        self.jotMenuConfigurations = jotMenuConfigurations
        self.onAction = onAction
        self.jot = jot
        self.repository = repository
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap: onAction()
        }
    }

    func didLoad(
        userInterfaceStyle: UIUserInterfaceStyle
    ) -> AsyncStream<UIImage?> {
        previewImageContinuation?.finish()
        let (stream, continuation) = AsyncStream.makeStream(
            of: UIImage?.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        previewImageContinuation = continuation
        loadPreviewImage(userInterfaceStyle: userInterfaceStyle)
        return stream
    }

    func didChangeTraitCollection(
        userInterfaceStyle: UIUserInterfaceStyle
    ) {
        loadPreviewImage(userInterfaceStyle: userInterfaceStyle)
    }

    private func loadPreviewImage(
        userInterfaceStyle: UIUserInterfaceStyle
    ) {
        previewImageTask?.cancel()
        let previewImageContinuation = previewImageContinuation
        previewImageTask = Task.detached { [weak self] in
            guard let self else {
                return
            }
            let previewImage = await repository.getPreviewImage(
                jotFileInfo: jot.toJotFileInfo(),
                userInterfaceStyle: userInterfaceStyle
            )
            previewImageContinuation?.yield(previewImage)
        }
    }

    func handleContextMenuConfiguration() -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self else {
                return nil
            }
            return UIMenu.make(jotMenuConfigurations: jotMenuConfigurations)
        }
    }

    deinit {
        previewImageTask?.cancel()
        previewImageContinuation?.finish()
    }
}
