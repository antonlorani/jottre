final class InfoTextViewModel {

    let text: String

    init(repository: InfoTextViewRepositoryProtocol) {
        text = repository.getText()
    }
}
