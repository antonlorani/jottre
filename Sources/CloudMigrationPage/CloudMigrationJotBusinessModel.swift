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

struct CloudMigrationJotBusinessModel: Sendable, Hashable {
    let name: String
    let lastModifiedText: String
    let isCloudSynchronized: Bool

    private let jotFileInfo: JotFile.Info

    init(
        jotFileInfo: JotFile.Info,
        isCloudSynchronized: Bool
    ) {
        name = jotFileInfo.name
        lastModifiedText =
            jotFileInfo.modificationDate.map {
                DateFormatter.localizedString(
                    from: $0,
                    dateStyle: .long,
                    timeStyle: .short
                )
            } ?? String()
        self.isCloudSynchronized = isCloudSynchronized
        self.jotFileInfo = jotFileInfo
    }

    func toJotFileInfo() -> JotFile.Info {
        jotFileInfo
    }
}
