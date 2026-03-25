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

/// Allows conformances to be converted to a ``URL``.
protocol URLConvertible: Sendable {

    var scheme: String? { get }
    var host: String? { get }
    var path: String { get }

    func toURL() -> URL
}

extension URLConvertible {

    var scheme: String? {
        nil
    }

    var host: String? {
        nil
    }

    func toURL() -> URL {
        assert(path.starts(with: "/"))
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        guard let url = components.url else {
            preconditionFailure()
        }
        return url
    }
}
