@MainActor
protocol PageCellViewModel: Sendable {

    func handle(action: PageCellAction)
}
