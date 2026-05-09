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

final class LoggerMock: LoggerProtocol, @unchecked Sendable {

    private let debugProvider: @Sendable (_ message: String) -> Void
    private let infoProvider: @Sendable (_ message: String) -> Void
    private let errorProvider: @Sendable (_ message: String) -> Void

    init(
        debugProvider: @Sendable @escaping (_ message: String) -> Void = { _ in },
        infoProvider: @Sendable @escaping (_ message: String) -> Void = { _ in },
        errorProvider: @Sendable @escaping (_ message: String) -> Void = { _ in }
    ) {
        self.debugProvider = debugProvider
        self.infoProvider = infoProvider
        self.errorProvider = errorProvider
    }

    func debug(_ message: @autoclosure () -> String) { debugProvider(message()) }
    func info(_ message: @autoclosure () -> String) { infoProvider(message()) }
    func error(_ message: @autoclosure () -> String) { errorProvider(message()) }
}
