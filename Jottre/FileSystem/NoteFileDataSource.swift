import Foundation
import PencilKit

struct NoteFileDataSource {

    private let defaults: DefaultsProtocol
    private let localFileDataSource: LocalFileDataSource
    private let remoteFileDataSource: RemoteFileDataSource

    init(
        defaults: DefaultsProtocol,
        localFileDataSource: LocalFileDataSource,
        remoteFileDataSource: RemoteFileDataSource
    ) {
        self.defaults = defaults
        self.localFileDataSource = localFileDataSource
        self.remoteFileDataSource = remoteFileDataSource
    }

    func createNote(name: String) -> URL? {
        let directory = (defaults.get(UsingCloudEntry()) == false) ? localFileDataSource.getDirectory() : remoteFileDataSource.getDirectory()
        guard let url = directory?.appendingPathComponent(name).appendingPathExtension("jot"),
              postNote(url: url, note: Note(drawing: PKDrawing()))
        else {
            return nil
        }
        return url
    }

    func postNote(url: URL, note: Note) -> Bool {
        guard let data = try? PropertyListEncoder().encode(note) else {
            return false
        }
        return localFileDataSource.setFileData(url: url, data: data)
    }

    func getNote(url: URL) -> NoteBusinessModel? {
        guard let noteBusinessModel = localFileDataSource
            .getFileData(url: url)
            .map({ data in
                (try? PropertyListDecoder().decode(Note.self, from: data))
                    .map { note in
                        NoteBusinessModel(
                            file: File(
                                name: localFileDataSource.getName(url: url),
                                url: url,
                                modificationDate: localFileDataSource.getModifiedDate(url: url)
                            ),
                            note: note
                        )
                    }
            }) else {
            return nil
        }
        return noteBusinessModel
    }
}
