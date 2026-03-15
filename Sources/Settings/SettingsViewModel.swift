@MainActor
final class SettingsViewModel: Sendable {
    
    enum Item {
        case dropdown(name: String)
        case toggle(name: String, isOn: Bool)
        case externalLink(name: String, onAction: () -> Void)
        case text(name: String, value: String)
    }
    
    private var items = [Item]()
    
    private weak var coordinator: SettingsCoordinator?
    
    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
    }
    
    func didTapCloseButton() {
        coordinator?.dismiss()
    }
}
