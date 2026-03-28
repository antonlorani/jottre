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

protocol CloudMigrationRepositoryProtocol: Sendable {

    func getShouldShowCloudMigration() async throws -> Bool
    func markCloudMigrationPageDone()
}

struct CloudMigrationRepository: CloudMigrationRepositoryProtocol {

    private let fileService: FileServiceProtocol
    private let defaultsService: DefaultsServiceProtocol

    init(
        fileService: FileServiceProtocol,
        defaultsService: DefaultsServiceProtocol
    ) {
        self.fileService = fileService
        self.defaultsService = defaultsService
    }

    func getShouldShowCloudMigration() async throws -> Bool {
        guard defaultsService.getValue(.hasDoneCloudMigration) == false else {
            return false
        }

        let isICloudEnabled = try await fileService.cloudDocumentsDirectory() != nil
        if let wasICloudEnabled = defaultsService.getValue(.isICloudEnabled) {
            return wasICloudEnabled != isICloudEnabled
        }

        if !isICloudEnabled {
            defaultsService.set(.isICloudEnabled, value: false)
        }

        return false
    }

    func markCloudMigrationPageDone() {
        defaultsService.set(.hasDoneCloudMigration, value: true)
    }
}
