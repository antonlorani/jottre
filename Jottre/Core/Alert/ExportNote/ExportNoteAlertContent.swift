struct ExportNoteAlertContent {
    let title: String
    let cancelActionTitle: String
    let actions: [ExportAction]
}

struct ExportAction {
    let title: String
    var onSelect: () -> Void
}
