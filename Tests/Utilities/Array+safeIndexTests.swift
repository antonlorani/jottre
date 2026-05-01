import XCTest

@testable import Jottre

final class ArraySafeIndexTests: XCTestCase {

    func test_safeSubscript_givenIndexInBounds_returnsElement() {
        // Given
        let array = [10, 20, 30]

        // When
        let element = array[safe: 1]

        // Then
        XCTAssertEqual(element, 20)
    }

    func test_safeSubscript_givenIndexOutOfBounds_returnsNil() {
        // Given
        let array = [10, 20, 30]

        // When
        let element = array[safe: 5]

        // Then
        XCTAssertNil(element)
    }

    func test_safeSubscript_givenEmptyArray_returnsNil() {
        // Given
        let array: [Int] = []

        // When
        let element = array[safe: 0]

        // Then
        XCTAssertNil(element)
    }
}
