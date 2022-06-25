import UIKit
import Combine

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
        tableView.register(PreferencesCell.self)
        return tableView
    }()

    private var itemsCancellable: AnyCancellable?
    private var userInterfaceStyleCancellable: AnyCancellable?
    private var retainedSwitchViewProviders = [IndexPath: SwitchViewProvider]()
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

        let cell = tableView.dequeueReusableCell(PreferencesCell.self)

        switch item {
        case let .image(title, image, _):
            cell.configure(title: title, customViewProvider: ImageViewProvider(image: image))
        case let .switch(title, isOn, isEnabled, onClick):
            configureCellWithSwitchView(
                cell: cell,
                title: title,
                isOn: isOn,
                isEnabled: isEnabled,
                onClick: onClick,
                indexPath: indexPath
            )
        case let.text(title, text, _):
            cell.configure(title: title, customViewProvider: TextViewProvider(text: text))
        }
        return cell
    }

    private func configureCellWithSwitchView(
        cell: PreferencesCell,
        title: String,
        isOn: Bool,
        isEnabled: Bool,
        onClick: @escaping (Bool) -> Void,
        indexPath: IndexPath
    ) {
        let switchViewProvider: SwitchViewProvider
        if let retainedSwitchViewProvider = retainedSwitchViewProviders[indexPath] {
            retainedSwitchViewProvider.reuse(
                isOn: isOn,
                isEnabled: isEnabled,
                onClick: onClick
            )
            switchViewProvider = retainedSwitchViewProvider
        } else {
            let newSwitchViewProvider = SwitchViewProvider(
                isOn: isOn,
                isEnabled: isEnabled,
                onClick: onClick
            )
            retainedSwitchViewProviders[indexPath] = newSwitchViewProvider
            switchViewProvider = newSwitchViewProvider
        }

        cell.configure(title: title, customViewProvider: switchViewProvider)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].onClick?()
    }
}
