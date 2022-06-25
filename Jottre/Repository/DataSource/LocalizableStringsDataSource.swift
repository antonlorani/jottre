import func Foundation.NSLocalizedString

protocol LocalizableStringsDataSourceProtocol {

    func getText(identifier: String) -> String
}

final class LocalizableStringsDataSource: LocalizableStringsDataSourceProtocol {

    static let shared = LocalizableStringsDataSource()

    func getText(identifier: String) -> String {
        NSLocalizedString(identifier, comment: String())
    }
}
