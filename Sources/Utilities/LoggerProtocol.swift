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
import OSLog

protocol LoggerProtocol: Sendable {

    func debug(_ message: @autoclosure () -> String)
    func info(_ message: @autoclosure () -> String)
    func error(_ message: @autoclosure () -> String)
}

struct OSLogLogger: LoggerProtocol {

    private let logger: Logger

    init(category: String) {
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "",
            category: category
        )
    }

    func debug(_ message: @autoclosure () -> String) {
        #if DEBUG
        let resolved = message()
        logger.debug("\(resolved)")
        #endif
    }

    func info(_ message: @autoclosure () -> String) {
        let resolved = message()
        logger.info("\(resolved)")
    }

    func error(_ message: @autoclosure () -> String) {
        let resolved = message()
        logger.error("\(resolved)")
    }
}
