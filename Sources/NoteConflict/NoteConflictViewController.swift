import UIKit

final class NoteConflictViewController: UIViewController {

    private enum Constants {
        enum Headline {
            static let font = {
                let font = UIFont.preferredFont(forTextStyle: .largeTitle)
                return UIFont.boldSystemFont(ofSize: font.pointSize)
            }()
        }

        enum Subheadline {
            static let font = {
                let font = UIFont.preferredFont(forTextStyle: .subheadline)
                return UIFont.boldSystemFont(ofSize: font.pointSize)
            }()
        }

        enum CollectionViewFlowLayout {
            static let inset = CGFloat(16)
            static let spacing = CGFloat(8)
            static let itemHeight = CGFloat(68)
        }
    }

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "iCloud is ready"
        label.font = Constants.Headline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subheadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Jots can now sync across all your devices. Choose which ones to bring along."
        label.font = Constants.Subheadline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var keepBothButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Keep Both"
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in

            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let viewModel: NoteConflictViewModel

    init(viewModel: NoteConflictViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(headlineLabel)
        view.addSubview(subheadlineLabel)
        view.addSubview(keepBothButton)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 42),
            headlineLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            subheadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subheadlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            subheadlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),

            keepBothButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            keepBothButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            keepBothButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            keepBothButton.heightAnchor.constraint(equalToConstant: 59),
        ])
    }
}
