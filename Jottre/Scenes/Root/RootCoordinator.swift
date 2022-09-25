import UIKit
import Combine

final class RootCoordinator: Coordinator {

    var release: CoordinatorReleaseClosure?

    private var retainedPreferencesCoordinator: PreferencesCoordinator?
    private var retainedNoteCoordinator: NoteCoordinator?
    private var retainedAddNoteCoordinator: AddNoteCoordinator?


    private let navigationController: UINavigationController
    private let defaults: DefaultsProtocol
    private let deviceDataSource: DeviceDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let openURLProvider: (URL) -> Void

    init(
        navigationController: UINavigationController,
        defaults: DefaultsProtocol,
        deviceDataSource: DeviceDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        openURLProvider: @escaping (URL) -> Void
    ) {
        self.navigationController = navigationController
        self.defaults = defaults
        self.deviceDataSource = deviceDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
        self.openURLProvider = openURLProvider
    }

    func start() {
        let rootViewController = RootViewController(
            viewModel: RootViewModel(
                coordinator: self,
                repository: RootRepository(
                    deviceDataSource: deviceDataSource,
                    localizableStringsDataSource: localizableStringsDataSource,
                    infoTextRepository: InfoTextViewRepository(
                        environmentDataSource: EnvironmentDataSource(
                            defaults: defaults,
                            cloudDataSource: cloudDataSource,
                            deviceDataSource: deviceDataSource
                        ),
                        localizableStringsDataSource: localizableStringsDataSource
                    ),
                    fileRepository: FileRepository(
                        defaults: Defaults.shared,
                        localFileDataSource: .shared,
                        fileSystem: FileSystem(
                            defaults: Defaults.shared,
                            localFileDataSource: .shared,
                            remoteFileDataSource: RemoteFileDataSource(
                                fileManager: .default,
                                localFileDataSource:.shared
                            )
                        )
                    )
                ),
                localizableStringsDataSource: localizableStringsDataSource
            )
        )
        navigationController.pushViewController(rootViewController, animated: false)
    }

    func showAddNoteAlert() {
        let addNoteCoordinator = AddNoteCoordinator(
            navigationController: navigationController,
            repository: AddNoteRepository(
                localizableStringsDataSource: localizableStringsDataSource
            )
        )
        retainedAddNoteCoordinator = addNoteCoordinator

        var cancellable: AnyCancellable?
        cancellable = addNoteCoordinator
            .startFlow()
            .sink { [weak self] noteBusinessModel in
                if let noteBusinessModel = noteBusinessModel {
                    self?.openNote(noteBusinessModel: noteBusinessModel)
                }

                cancellable?.cancel()
                cancellable = nil
                self?.retainedAddNoteCoordinator = nil
            }
    }

    func openPreferences() {
        let preferencesCoordinator = PreferencesCoordinator(
            navigationController: navigationController,
            defaults: defaults,
            deviceDataSource: deviceDataSource,
            cloudDataSource: cloudDataSource,
            localizableStringsDataSource: localizableStringsDataSource,
            openURLProvider: openURLProvider
        )
        retainedPreferencesCoordinator = preferencesCoordinator
        preferencesCoordinator.start()
        preferencesCoordinator.release = { [weak self] in
            self?.retainedPreferencesCoordinator = nil
        }
    }

    func openNote(noteBusinessModel: NoteBusinessModel) {
        let noteCoordinator = NoteCoordinator(
            navigationController: navigationController,
            noteBusinessModel: noteBusinessModel
        )
        retainedNoteCoordinator = noteCoordinator
        noteCoordinator.start()
        noteCoordinator.release = { [weak self] in
            self?.retainedNoteCoordinator = nil
        }
    }
}
