import func Foundation.NSLocalizedString

protocol LocalizableStringsDataSourceProtocol {

    func getText(identifier: String) -> String
}

final class LocalizableStringsDataSource: LocalizableStringsDataSourceProtocol {

    func getText(identifier: String) -> String {
        NSLocalizedString(identifier, comment: String())
    }
}
