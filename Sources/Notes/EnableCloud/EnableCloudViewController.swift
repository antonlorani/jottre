import UIKit

final class EnableCloudViewController: UIViewController {

    private enum Constants {
        static let horizontalPadding = CGFloat(16)
        static let itemSpacing = CGFloat(8)
        static let learnButtonHeight = CGFloat(56)
        static let scrollContentTopInset = CGFloat(24)
        static let featureIconSize = CGFloat(28)
        static let featureRowCornerRadius = CGFloat(12)
        static let featureRowPadding = CGFloat(16)
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Constants.itemSpacing
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enable iCloud"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "It looks like iCloud is disabled on this device. Turn on iCloud to get the most out of Jottre."
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var learnButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Learn How To Enable"
        configuration.image = UIImage(systemName: "arrow.up.forward")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .bold)
            return outgoing
        }
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapLearnHowToEnable()
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let viewModel: EnableCloudViewModel
    private let closeBarButtonItemFactory: BarButtonItemFactory

    init(viewModel: EnableCloudViewModel, closeBarButtonItemFactory: BarButtonItemFactory) {
        self.viewModel = viewModel
        self.closeBarButtonItemFactory = closeBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpViews()
    }

    private func setUpNavigationItem() {
        navigationItem.rightBarButtonItem = closeBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapCloseButton()
            }
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(scrollView)
        view.addSubview(learnButton)

        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.setCustomSpacing(16, after: titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.setCustomSpacing(24, after: descriptionLabel)
        contentStackView.addArrangedSubview(
            makeFeatureRow(
                systemImageName: "macbook.and.iphone",
                text: "Synchronize jots across all your Apple devices"
            )
        )
        contentStackView.addArrangedSubview(
            makeFeatureRow(
                systemImageName: "person.3.fill",
                text: "Share jots with others"
            )
        )

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: learnButton.topAnchor,
                constant: -Constants.horizontalPadding
            ),

            contentStackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: Constants.scrollContentTopInset
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: -Constants.horizontalPadding
            ),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Constants.horizontalPadding * 2)
            ),

            learnButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            learnButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            learnButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.horizontalPadding
            ),
            learnButton.heightAnchor.constraint(equalToConstant: Constants.learnButtonHeight),
        ])
    }

    private func makeFeatureRow(systemImageName: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemGroupedBackground
        containerView.layer.cornerRadius = Constants.featureRowCornerRadius
        containerView.clipsToBounds = true

        let imageView = UIImageView(image: UIImage(systemName: systemImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0

        containerView.addSubview(imageView)
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.featureRowPadding
            ),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.featureIconSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.featureIconSize),

            label.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: Constants.featureRowPadding
            ),
            label.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.featureRowPadding
            ),
            label.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.featureRowPadding
            ),
            label.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Constants.featureRowPadding
            ),
        ])

        return containerView
    }
}
