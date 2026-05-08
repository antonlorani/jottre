import XCTest

@testable import Jottre

@MainActor
final class EnableCloudViewModelTests: XCTestCase {

    func test_items_givenInit_yieldsHeaderAndTwoFeatureRows() async throws {
        // Given
        let viewModel = EnableCloudViewModel(coordinator: EnableCloudCoordinatorMock())

        // When
        let items = try await firstValue(of: viewModel.items)

        // Then
        XCTAssertEqual(items.count, 3)
    }

    func test_rightNavigationItems_givenInit_yieldsXmarkSymbol() async throws {
        // Given
        let viewModel = EnableCloudViewModel(coordinator: EnableCloudCoordinatorMock())

        // When
        let items = try await firstValue(of: viewModel.rightNavigationItems)

        // Then
        XCTAssertEqual(items.count, 1)
        guard case let .symbol(systemImageName, _) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        XCTAssertEqual(systemImageName, "xmark")
    }

    func test_rightNavigationItem_givenTap_invokesCoordinatorDismiss() async throws {
        // Given
        let dismissExpectation = XCTestExpectation(description: "EnableCloudCoordinatorMock.dismiss is called.")
        let coordinator = EnableCloudCoordinatorMock(
            dismissProvider: { dismissExpectation.fulfill() }
        )
        let viewModel = EnableCloudViewModel(coordinator: coordinator)

        // When
        let items = try await firstValue(of: viewModel.rightNavigationItems)
        guard case let .symbol(_, onAction) = items[0] else {
            XCTFail("Expected .symbol")
            return
        }
        onAction()
        await Task.yield()

        // Then
        await fulfillment(of: [dismissExpectation], timeout: 1)
    }

    func test_actions_givenLearnHowToEnableTap_invokesCoordinatorOpenLearnHowToEnable() async throws {
        // Given
        let openExpectation = XCTestExpectation(
            description: "EnableCloudCoordinatorMock.openLearnHowToEnable is called."
        )
        let coordinator = EnableCloudCoordinatorMock(
            openLearnHowToEnableProvider: { openExpectation.fulfill() }
        )
        let viewModel = EnableCloudViewModel(coordinator: coordinator)

        // When
        XCTAssertEqual(viewModel.actions.count, 1)
        viewModel.actions[0].action()
        await Task.yield()

        // Then
        await fulfillment(of: [openExpectation], timeout: 1)
    }
}

@MainActor
private func firstValue<S: AsyncSequence & Sendable>(
    of sequence: S
) async throws -> S.Element where S.Element: Sendable {
    var iterator = sequence.makeAsyncIterator()
    guard let value = try await iterator.next() else {
        throw NSError(domain: "EnableCloudViewModelTests", code: 0)
    }
    return value
}
