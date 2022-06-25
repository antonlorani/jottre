protocol InfoTextViewRepositoryProtocol {

    func getText() -> String
}

final class InfoTextViewRepository: InfoTextViewRepositoryProtocol {

    private let environmentDataSource: EnvironmentDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        environmentDataSource: EnvironmentDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.environmentDataSource = environmentDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getText() -> String {
        getText(
            canUseCloud: environmentDataSource.getCanUseCloud(),
            isReadOnly: environmentDataSource.getIsReadOnly()
        )
    }

    private func getText(
        canUseCloud: Bool,
        isReadOnly: Bool
    ) -> String {
        let identifier: String
        if canUseCloud {
            if isReadOnly {
                identifier = "Scene.Root.Info.DocumentsNotAvailable.other"
            } else {
                identifier = "Scene.Root.Info.DocumentsNotAvailable.pad"
            }
        } else {
            if isReadOnly {
                identifier = "Scene.Root.Info.EnableCloud.other"
            } else {
                identifier = "Scene.Root.Info.EnableCloud.pad"
            }
        }
        return localizableStringsDataSource.getText(identifier: identifier)
    }
}
