import XCTest

@testable import Jottre

final class UbiquitousInfoTests: XCTestCase {

    func test_equality_givenSameValues_returnsEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)

        // Then
        XCTAssertEqual(lhs, rhs)
    }

    func test_equality_givenDifferentDownloadStatus_returnsNotEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .notDownloaded, isDownloading: false)

        // Then
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_givenDifferentIsDownloading_returnsNotEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: .current, isDownloading: false)
        let rhs = UbiquitousInfo(downloadStatus: .current, isDownloading: true)

        // Then
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_equality_givenNilDownloadStatusOnBoth_returnsEqual() {
        // Given
        let lhs = UbiquitousInfo(downloadStatus: nil, isDownloading: true)
        let rhs = UbiquitousInfo(downloadStatus: nil, isDownloading: true)

        // Then
        XCTAssertEqual(lhs, rhs)
    }
}
