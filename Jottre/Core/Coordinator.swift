typealias CoordinatorReleaseClosure = (() -> Void)

protocol Coordinator {
    var release: CoordinatorReleaseClosure? { get set }
    func start()
}
