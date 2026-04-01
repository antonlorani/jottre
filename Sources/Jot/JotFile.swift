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

struct JotFile: Sendable {

    struct Info: Sendable, Hashable {
        static let fileExtension = "jot"

        let url: URL
        let name: String
        let modificationDate: Date?
        let isUbiquitous: Bool

        init(
            url: URL,
            name: String,
            modificationDate: Date?,
            isUbiquitous: Bool
        ) {
            self.url = url
            self.name = name
            self.modificationDate = modificationDate
            self.isUbiquitous = isUbiquitous
        }

        init?(
            url: URL,
            modificationDate: Date?,
            isUbiquitous: Bool
        ) {
            guard url.pathExtension == Info.fileExtension else {
                return nil
            }
            self.init(
                url: url,
                name: url.deletingPathExtension().lastPathComponent,
                modificationDate: modificationDate,
                isUbiquitous: isUbiquitous
            )
        }
    }

    let info: Info
    let jot: Jot
}
