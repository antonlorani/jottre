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

        enum NotesStack {
            static let spacing = CGFloat(8)
            static let itemHeight = CGFloat(250)
        }
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        return scrollView
    }()

    private let scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Headline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subheadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Subheadline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var notesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.NotesStack.spacing
        return stackView
    }()

    private lazy var callToActionStackView = CallToActionStackView(buttons: viewModel.actions)

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
        isModalInPresentation = true
        view.backgroundColor = .systemGroupedBackground
        view.directionalLayoutMargins.bottom = 16

        headlineLabel.text = viewModel.headline
        subheadlineLabel.text = viewModel.subheadline

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(headlineLabel)
        scrollContentView.addSubview(subheadlineLabel)
        scrollContentView.addSubview(notesStackView)
        view.addSubview(callToActionStackView)

        for noteItem in viewModel.notes {
            let cell = NoteCell(frame: .zero)
            cell.configure(note: noteItem.note, infoText: noteItem.infoText)
            notesStackView.addArrangedSubview(cell)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: callToActionStackView.topAnchor, constant: -16),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headlineLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 42),
            headlineLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            subheadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subheadlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            subheadlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),

            notesStackView.topAnchor.constraint(equalTo: subheadlineLabel.bottomAnchor, constant: 24),
            notesStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            notesStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            notesStackView.heightAnchor.constraint(equalToConstant: Constants.NotesStack.itemHeight),
            notesStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -16),

            callToActionStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            callToActionStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            callToActionStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

}
