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

    func getPreviewImage(
        userInterfaceStyle: UIUserInterfaceStyle
    ) async -> UIImage? {
        let task = Task.detached { [weak self] in
            guard let self else {
                return nil as UIImage?
            }
            return await self.repository.getPreviewImage(
                jotFileInfo: self.cloudMigrationJot.toJotFileInfo(),
                userInterfaceStyle: userInterfaceStyle
            )
        }
        return await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
    }
}
