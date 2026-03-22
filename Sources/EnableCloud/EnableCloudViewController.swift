import UIKit

final class EnableCloudViewController: UIViewController {

    private enum Constants {
        static let itemSpacing = CGFloat(8)
        static let featureIconSize = CGFloat(28)
        static let featureRowCornerRadius = CGFloat(20)
        static let featureRowPadding = CGFloat(16)
    }

    private lazy var pageHeaderView: PageHeaderView = {
        let view = PageHeaderView(configuration: viewModel.pageHeaderConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        view.directionalLayoutMargins.bottom = 16

        view.addSubview(pageHeaderView)
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentStackView)
        view.addSubview(callToActionView)

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
            pageHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            contentScrollView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: 24),
            contentScrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: callToActionView.topAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),

            callToActionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            callToActionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            callToActionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
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
