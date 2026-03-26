import Foundation

struct JotFile: Sendable {

    struct Info: Sendable, Hashable {
        let url: URL
        let name: String
        let modificationDate: Date?
    }

    let info: Info
    let jot: Jot
}

struct JotFileVersion: Sendable {
    let info: JotFile.Info
}
