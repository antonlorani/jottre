protocol ReusableCell {

    static var reuseIdentifier: String { get }
}

extension ReusableCell {

    static var reuseIdentifier: String {
        "\(Self.self)"
    }
}
