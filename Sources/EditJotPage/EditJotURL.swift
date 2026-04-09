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

struct EditJotURL: URLConvertible {
    static let path = "/jots/edit"

    let path: String = Self.path
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(
                name: "fileURL",
                value: fileURL.absoluteString
            )
        ]
    }

    let fileURL: URL

    init(jotFileInfo: JotFile.Info) {
        fileURL = jotFileInfo.url
    }

    init?(url: URL) {
        guard
            url.path.hasPrefix(EditJotURL.path),
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let fileURLValue = urlComponents.queryItems?.first(where: { $0.name == "fileURL" })?.value,
            let fileURL = URL(string: fileURLValue)
        else {
            return nil
        }

        self.fileURL = fileURL
    }
}
