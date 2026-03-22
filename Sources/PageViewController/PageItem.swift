struct PageItem: Sendable {

    enum Content: Sendable {
        case pageHeader(PageHeaderBusinessModel)
        case featureRow(FeatureRowBusinessModel)
        case migrationNote(CloudMigrationNoteBusinessModel, onAction: @MainActor @Sendable () -> Void)
        case note(NoteBusinessModel, infoText: String?, onAction: @MainActor @Sendable () -> Void)
    }
    
    let content: Content
    let sizing: PageItemSizing
}
