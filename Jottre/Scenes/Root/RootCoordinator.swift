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
    private let localFileDataSource: LocalFileDataSource
    private let remoteFileDataSource: RemoteFileDataSource
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    private let openURLProvider: (URL) -> Void

    init(
        navigationController: UINavigationController,
        defaults: DefaultsProtocol,
        deviceDataSource: DeviceDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localFileDataSource: LocalFileDataSource,
        remoteFileDataSource: RemoteFileDataSource,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol,
        openURLProvider: @escaping (URL) -> Void
    ) {
        self.navigationController = navigationController
        self.defaults = defaults
        self.deviceDataSource = deviceDataSource
        self.cloudDataSource = cloudDataSource
        self.localFileDataSource = localFileDataSource
        self.remoteFileDataSource = remoteFileDataSource
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
                        localFileDataSource: localFileDataSource,
                        fileSystem: FileSystem(
                            defaults: Defaults.shared,
                            localFileDataSource: localFileDataSource,
                            remoteFileDataSource: RemoteFileDataSource(
                                fileManager: .default,
                                localFileDataSource: localFileDataSource
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
                localizableStringsDataSource: localizableStringsDataSource,
                noteDataSource: NoteFileDataSource(
                    defaults: defaults,
                    localFileDataSource: localFileDataSource,
                    remoteFileDataSource: remoteFileDataSource
                )
            )
        )
        retainedAddNoteCoordinator = addNoteCoordinator

        var cancellable: AnyCancellable?
        cancellable = addNoteCoordinator
            .startFlow()
            .sink { [weak self] url in
                if let url = url {
                    self?.openNote(url: url)
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

    func openNote(url: URL) {
        let noteCoordinator = NoteCoordinator(
            defaults: defaults,
            localFileDataSource: localFileDataSource,
            remoteFileDataSource: remoteFileDataSource,
            navigationController: navigationController,
            url: url
        )
        retainedNoteCoordinator = noteCoordinator
        noteCoordinator.start()
        noteCoordinator.release = { [weak self] in
            self?.retainedNoteCoordinator = nil
        }
    }
}
