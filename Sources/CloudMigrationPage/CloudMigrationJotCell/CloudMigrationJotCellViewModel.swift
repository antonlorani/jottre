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

final class CloudMigrationJotCellViewModel: PageCellViewModel {

    let name: String
    let infoText: String
    let isCloudCheckboxOn: Bool
    let onTap: @Sendable () -> Void

    private var previewImageContinuation: AsyncStream<UIImage?>.Continuation?
    private var previewImageTask: Task<Void, Never>?

    private let cloudMigrationJot: CloudMigrationJotBusinessModel
    private let repository: CloudMigrationRepositoryProtocol

    init(
        cloudMigrationJot: CloudMigrationJotBusinessModel,
        repository: CloudMigrationRepositoryProtocol,
        onTap: @Sendable @escaping () -> Void
    ) {
        name = cloudMigrationJot.name
        infoText = cloudMigrationJot.lastModifiedText
        isCloudCheckboxOn = cloudMigrationJot.isCloudSynchronized
        self.cloudMigrationJot = cloudMigrationJot
        self.repository = repository
        self.onTap = onTap
    }

    func handle(action: PageCellAction) {
        switch action {
        case .tap:
            onTap()
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
                jotFileInfo: cloudMigrationJot.toJotFileInfo(),
                userInterfaceStyle: userInterfaceStyle
            )
            previewImageContinuation?.yield(previewImage)
        }
    }

    deinit {
        previewImageTask?.cancel()
        previewImageContinuation?.finish()
    }
}
