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

    enum NoteConflict {
        static let title = String(localized: "noteConflict.title")

        static func subtitle(_ noteName: String) -> String {
            String(format: String(localized: "noteConflict.subtitle"), noteName)
        }

        enum Action {
            static let keepBoth = String(localized: "noteConflict.action.keepBoth")
            static let keepVersionA = String(localized: "noteConflict.action.keepVersionA")
            static let keepVersionB = String(localized: "noteConflict.action.keepVersionB")
        }
    }

    enum Notes {

        enum Create {
            static let namePlaceholder = String(localized: "notes.create.namePlaceholder")
            static let title = String(localized: "notes.create.title")
        }

        enum Delete {
            static let message = String(localized: "notes.delete.message")
            static let title = String(localized: "notes.delete.title")
        }

        enum Menu {
            static let showInFiles = String(localized: "notes.menu.showInFiles")
            static let showInFinder = String(localized: "notes.menu.showInFinder")
        }

        enum Rename {
            static let title = String(localized: "notes.rename.title")
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
}
