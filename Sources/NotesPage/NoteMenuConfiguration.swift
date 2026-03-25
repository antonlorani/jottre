enum NoteMenuConfiguration {

    struct Action {
        let title: String
        let systemImageName: String
        var isDestructive: Bool = false
        let handler: @Sendable () -> Void
    }

    struct Group {
        let title: String
        let systemImageName: String
        let actions: [Action]
    }

    case action(Action)
    case group(Group)
}
