struct SettingsDropdownBusinessModel: Sendable {

    struct Option: Sendable {
        let label: String
        let value: any Hashable & Sendable
    }

    let name: String
    let current: Option
    let options: [Option]
    let onAction: @Sendable (_ newOption: Option) -> Void
}
