@MainActor
protocol Coordinator: Sendable, AnyObject {

    var onEnd: (() -> Void)? { get set }

    func start()
}
