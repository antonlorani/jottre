import UIKit

final class PageCallToActionView: UIStackView {

    struct ActionConfiguration {
        enum Style {
            case primary
            case secondary
        }
        let style: Style
        let title: String
        let icon: String?
        let action: () -> Void
    }

    init(actions: [ActionConfiguration]) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        for action in actions {
            addArrangedSubview(makeButton(action: action))
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func layoutSubviews() {
        if let windowBounds = window?.bounds, windowBounds.width > windowBounds.height {
            axis = .horizontal
            distribution = .fillEqually
        } else {
            axis = .vertical
            distribution = .fill
        }
        super.layoutSubviews()
    }

    private func makeButton(action: ActionConfiguration) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        switch action.style {
        case .primary:
            configuration.baseBackgroundColor = .label
            configuration.baseForegroundColor = .systemBackground
        case .secondary:
            configuration.baseBackgroundColor = .secondarySystemGroupedBackground
            configuration.baseForegroundColor = .label
        }
        configuration.title = action.title
        if let iconName = action.icon {
            configuration.image = UIImage(systemName: iconName)
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 8
        }
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { _ in
                action.action()
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}
