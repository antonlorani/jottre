import UIKit

final class NoteConflictViewController: UIViewController {

    private enum Constants {
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

    private lazy var pageHeaderView: PageHeaderView = {
        let view = PageHeaderView(configuration: viewModel.pageHeaderConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var notesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.NotesStack.spacing
        return stackView
    }()

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        isModalInPresentation = true
        view.backgroundColor = .systemGroupedBackground
        view.directionalLayoutMargins.bottom = 16

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(pageHeaderView)
        scrollContentView.addSubview(notesStackView)
        view.addSubview(callToActionView)

        for noteItem in viewModel.notes {
            let cell = NoteCell(frame: .zero)
            cell.configure(note: noteItem.note, infoText: noteItem.infoText)
            notesStackView.addArrangedSubview(cell)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: callToActionView.topAnchor, constant: -16),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            pageHeaderView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 42),
            pageHeaderView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            notesStackView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: 24),
            notesStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            notesStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            notesStackView.heightAnchor.constraint(equalToConstant: Constants.NotesStack.itemHeight),
            notesStackView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -16),

            callToActionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            callToActionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            callToActionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

}
