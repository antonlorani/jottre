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

enum L10n {

    enum Action {
        static let cancel = String(localized: "action.cancel")
        static let create = String(localized: "action.create")
        static let delete = String(localized: "action.delete")
        static let done = String(localized: "action.done")
        static let duplicate = String(localized: "action.duplicate")
        static let rename = String(localized: "action.rename")
        static let share = String(localized: "action.share")
    }

    enum App {
        static let title = String(localized: "app.title")
    }

    enum CloudMigration {
        static let subtitle = String(localized: "cloudMigration.subtitle")
        static let title = String(localized: "cloudMigration.title")

        enum ErrorAlert {

            static func title(_ jotName: String) -> String {
                String(format: String(localized: "cloudMigration.errorAlert.title"), jotName)
            }
        }
    }

    enum EnableCloud {
        static let subtitle = String(localized: "enableCloud.subtitle")
        static let title = String(localized: "enableCloud.title")

        enum Action {
            static let learnHowToEnable = String(localized: "enableCloud.action.learnHowToEnable")
        }

        enum Feature {
            static let share = String(localized: "enableCloud.feature.share")
            static let sync = String(localized: "enableCloud.feature.sync")
        }
    }

    enum JotConflict {
        static let title = String(localized: "jotConflict.title")

        enum Error {
            static let generic = String(localized: "static let  jotConflict.error.generic")
        }

        static func subtitle(_ jotName: String) -> String {
            String(format: String(localized: "jotConflict.subtitle"), jotName)
        }

        enum Action {
            static let keepAll = String(localized: "jotConflict.action.keepAll")

            static func keepVersion(_ version: String) -> String {
                String(format: String(localized: "jotConflict.action.keepVersion"), version)
            }
        }
    }

    enum Jots {

        enum Create {
            static let namePlaceholder = String(localized: "jots.create.namePlaceholder")
            static let title = String(localized: "jots.create.title")

            enum Error {
                static let generic = String(localized: "jots.create.error.generic")

                static func fileExists(_ jotName: String) -> String {
                    String(format: String(localized: "jots.create.error.fileExists"), jotName)
                }
            }
        }

        enum Delete {
            static let message = String(localized: "jots.delete.message")
            static let title = String(localized: "jots.delete.title")

            enum Error {
                static func generic(_ jotName: String) -> String {
                    String(format: String(localized: "jots.delete.error.generic"), jotName)
                }
            }
        }

        enum Menu {
            static let revealInFiles = String(localized: "jots.menu.revealInFiles")
            static let revealInFinder = String(localized: "jots.menu.revealInFinder")
        }

        enum Duplicate {

            enum Error {
                static func generic(_ jotName: String) -> String {
                    String(format: String(localized: "jots.duplicate.error.generic"), jotName)
                }
            }
        }

        enum Rename {
            static let title = String(localized: "jots.rename.title")

            enum Error {
                static func generic(_ jotName: String) -> String {
                    String(format: String(localized: "jots.rename.error.generic"), jotName)
                }
            }
        }
    }

    enum Settings {
        static let title = String(localized: "settings.title")

        enum Appearance {
            static let dark = String(localized: "settings.appearance.dark")
            static let light = String(localized: "settings.appearance.light")
            static let system = String(localized: "settings.appearance.system")
            static let title = String(localized: "settings.appearance.title")
        }

        enum Github {
            static let title = String(localized: "settings.github.title")
        }

        enum ICloud {
            static let info = String(localized: "settings.icloud.info")
            static let title = String(localized: "settings.icloud.title")
        }

        enum Version {
            static let title = String(localized: "settings.version.title")
        }
    }

    enum Share {

        enum Format {
            static let jpg = String(localized: "share.format.jpg")
            static let pdf = String(localized: "share.format.pdf")
            static let png = String(localized: "share.format.png")
        }
    }

    enum FileSystem {

        enum Duplicate {

            enum FileName {
                static func plain(_ jotName: String) -> String {
                    String(format: String(localized: "filesystem.duplicate.filename.plain"), jotName)
                }

                static func multi(_ jotName: String, _ duplicateCount: Int) -> String {
                    String(format: String(localized: "filesystem.duplicate.filename.multi"), jotName, duplicateCount)
                }
            }
        }
    }
}
