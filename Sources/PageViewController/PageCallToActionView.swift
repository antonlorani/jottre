/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit

final class PageCallToActionView: UIStackView {

    private enum Constants {

        static let height = CGFloat(50)
    }

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
        spacing = DesignTokens.Spacing.xs
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
            configuration.imagePadding = DesignTokens.Spacing.xs
        }
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .body, weight: .semibold)
            return outgoing
        }
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { _ in
                action.action()
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true
        return button
    }
}
