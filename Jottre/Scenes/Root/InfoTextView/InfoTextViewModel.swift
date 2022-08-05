import Combine

final class InfoTextViewModel {

    let infoTextString: AnyPublisher<String, Never>

    init(infoTextString: AnyPublisher<String?, Never>) {
        self.infoTextString = infoTextString
            .replaceNil(with: String())
            .eraseToAnyPublisher()
    }
}
