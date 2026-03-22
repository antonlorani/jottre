import UIKit

final class CallToActionStackView: UIStackView {

    struct ButtonConfiguration {
        enum Style {
            case primary
            case secondary
        }
        let style: Style
        let title: String
        let icon: String?
        let action: () -> Void
    }

    init(buttons: [ButtonConfiguration]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 8
        for config in buttons {
            addArrangedSubview(makeButton(for: config))
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

    private func makeButton(for config: ButtonConfiguration) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        switch config.style {
        case .primary:
            configuration.baseBackgroundColor = .label
            configuration.baseForegroundColor = .systemBackground
        case .secondary:
            configuration.baseBackgroundColor = .secondarySystemGroupedBackground
            configuration.baseForegroundColor = .label
        }
        configuration.title = config.title
        if let iconName = config.icon {
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
                config.action()
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}
