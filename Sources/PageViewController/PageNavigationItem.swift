enum PageNavigationItem: Sendable {
    case text(
        title: String,
        onAction: @Sendable () -> Void
    )
    case symbol(
        systemImageName: String,
        onAction: @Sendable () -> Void
    )
}
