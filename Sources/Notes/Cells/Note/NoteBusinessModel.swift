import UIKit

struct NoteBusinessModel: Sendable, Hashable {
    let previewImage: UIImage?
    let name: String
    let lastEditedDateString: String
    let isCloudSynchronized: Bool
}
