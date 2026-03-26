import Foundation

struct JotFileBusinessModel: Sendable {
    let name: String

    private let jotFileInfo: JotFile.Info

    init(jotFileInfo: JotFile.Info) {
        name = jotFileInfo.name
        self.jotFileInfo = jotFileInfo
    }

    init?(
        url: URL,
        modificationDate: Date?
    ) {
        guard url.pathExtension == "jot" else {
            return nil
        }
        let jotFileInfo = JotFile.Info(
            url: url,
            name: url.deletingPathExtension().lastPathComponent,
            modificationDate: modificationDate
        )
        self.init(jotFileInfo: jotFileInfo)
    }

    func toFileInfo() -> JotFile.Info {
        jotFileInfo
    }
}
