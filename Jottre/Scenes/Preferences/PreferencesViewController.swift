import UIKit
import Combine

extension UITableViewCell {

    static var reuseIdentifier: String {
        "\(Self.self)"
    }
}

final class PreferencesViewController: UIViewController {

    private struct Constants {
        static let backgroundColor = UIColor.systemBackground
    }

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = .leastNonzeroMagnitude
        tableView.separatorStyle = .none
        tableView.backgroundColor = Constants.backgroundColor
        tableView.register(PreferencesCell.self, forCellReuseIdentifier: PreferencesCell.reuseIdentifier)
        return tableView
    }()

    private var itemsCancellable: AnyCancellable?
    private var userInterfaceStyleCancellable: AnyCancellable?
    private var items = [PreferencesViewModel.Item]()

    private let viewModel: PreferencesViewModel

    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()
        setUpDelegates()
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        view.backgroundColor = Constants.backgroundColor

        navigationItem.title = viewModel.navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didClickDone(_:)))

        view.addSubview(tableView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func bindViewModel() {
        itemsCancellable = viewModel
            .items
            .sink { [weak self] newItems in
                self?.items = newItems
                self?.tableView.reloadData()
            }

        userInterfaceStyleCancellable = viewModel
            .customUserInterfaceStyle
            .sink { [weak self] newCustomUserInterfaceStyle in
                self?.view.animateTransition(newUserInterfaceStyle: newCustomUserInterfaceStyle.userInterfaceStyle)
            }
    }

    @objc private func didClickDone(_ sender: UIBarButtonItem) {
        viewModel.didClickDone()
    }
}

extension PreferencesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: PreferencesCell.reuseIdentifier) as? PreferencesCell else {
            return .init()
        }

        switch item {
        case let .image(title, image, _):
            cell.configure(title: title, customViewProvider: ImageViewProvider(image: image))
        case let .switch(title, isOn, isEnabled, onClick):
            cell.configure(title: title, customViewProvider: SwitchViewProvider(isOn: isOn, isEnabled: isEnabled, onClick: onClick))
        case let.text(title, text, _):
            cell.configure(title: title, customViewProvider: TextViewProvider(text: text))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].onClick?()
    }
}
