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

final class CreateJotCoordinator: Coordinator {

    var onEnd: (() -> Void)?

    private let navigation: Navigation

    init(navigation: Navigation) {
        self.navigation = navigation
    }

    func start() {
        let alertController = UIAlertController(
            title: L10n.Jots.Create.title,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.placeholder = L10n.Jots.Create.namePlaceholder
            textField.autocapitalizationType = .sentences
            textField.returnKeyType = .done
        }

        let createAction = UIAlertAction(
            title: L10n.Action.create,
            style: .default
        ) { [weak self] _ in
            guard
                let self,
                let title = alertController.textFields?.first?.text,
                !title.isEmpty
            else {
                return
            }
            navigation.open(url: EditJotURL().toURL())
        }
        alertController.addAction(createAction)

        let cancelAction = UIAlertAction(
            title: L10n.Action.cancel,
            style: .cancel
        )
        alertController.addAction(cancelAction)

        navigation.present(alertController, animated: true)
    }
}
