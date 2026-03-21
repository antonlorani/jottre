import UIKit

struct CloudMigrationNoteBusinessModel: Sendable {
    let previewImage: UIImage?
    let name: String
    let lastEditedDateString: String
    let isCloudSynchronized: Bool
}
