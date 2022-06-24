protocol InfoTextViewRepositoryProtocol {

    func getText() -> String
}

final class InfoTextViewRepository: InfoTextViewRepositoryProtocol {

    private let deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol
    private let cloudDataSource: CloudDataSourceProtocol
    private let localizableStringsDataSource: LocalizableStringsDataSourceProtocol

    init(
        deviceEnvironmentDataSource: DeviceEnvironmentDataSourceProtocol,
        cloudDataSource: CloudDataSourceProtocol,
        localizableStringsDataSource: LocalizableStringsDataSourceProtocol
    ) {
        self.deviceEnvironmentDataSource = deviceEnvironmentDataSource
        self.cloudDataSource = cloudDataSource
        self.localizableStringsDataSource = localizableStringsDataSource
    }

    func getText() -> String {
        getText(
            isCloudEnabled: cloudDataSource.getIsEnabled(),
            isReadOnlyDevice: deviceEnvironmentDataSource.getIsReadOnly()
        )
    }

    private func getText(isCloudEnabled: Bool, isReadOnlyDevice: Bool) -> String {
        let identifier: String
        if isCloudEnabled {
            if isReadOnlyDevice {
                identifier = "Scene.Root.Info.DocumentsNotAvailable.other"
            } else {
                identifier = "Scene.Root.Info.DocumentsNotAvailable.pad"
            }
        } else {
            if isReadOnlyDevice {
                identifier = "Scene.Root.Info.EnableCloud.other"
            } else {
                identifier = "Scene.Root.Info.EnableCloud.pad"
            }
        }
        return localizableStringsDataSource.getText(identifier: identifier)
    }
}
