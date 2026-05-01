import XCTest

@testable import Jottre

final class CachedJotFilePreviewImageServiceTests: XCTestCase {

    private let info = JotFile.Info(
        url: URL(staticString: "file:///tmp/note.jot"),
        name: "note",
        modificationDate: Date(timeIntervalSince1970: 1_000),
        ubiquitousInfo: nil
    )

    func test_getPreviewImageData_givenColdCache_callsUnderlyingServiceAndReturnsItsData() async throws {
        // Given
        let underlyingExpectation = XCTestExpectation(description: "Underlying service is called.")
        let expectedData = Data([1, 2, 3])
        let underlying = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { _, _, _ in
                underlyingExpectation.fulfill()
                return expectedData
            }
        )
        let service = CachedJotFilePreviewImageService(
            localFileService: FileServiceMock(
                readFileProvider: { _ in throw NSError(domain: "noDiskCache", code: 0) }
            ),
            jotFilePreviewImageService: underlying
        )

        // When
        let data = try await service.getPreviewImageData(
            jotFileInfo: info,
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertEqual(data, expectedData)
        await fulfillment(of: [underlyingExpectation], timeout: 0.5)
    }

    func test_getPreviewImageData_givenSecondCallWithSameKey_servesFromMemoryCache() async throws {
        // Given
        let underlyingCallCount = LockIsolated(0)
        let expectedData = Data([9, 8, 7])
        let underlying = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { _, _, _ in
                underlyingCallCount.withValue { $0 += 1 }
                return expectedData
            }
        )
        let service = CachedJotFilePreviewImageService(
            localFileService: FileServiceMock(
                readFileProvider: { _ in throw NSError(domain: "noDiskCache", code: 0) }
            ),
            jotFilePreviewImageService: underlying
        )

        // When
        _ = try await service.getPreviewImageData(jotFileInfo: info, userInterfaceStyle: .light, displayScale: 2.0)
        let second = try await service.getPreviewImageData(
            jotFileInfo: info,
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertEqual(second, expectedData)
        XCTAssertEqual(underlyingCallCount.value, 1)
    }

    func test_getPreviewImageData_givenDiskCacheHit_skipsUnderlyingService() async throws {
        // Given
        let cachedData = Data([42])
        let underlying = JotFilePreviewImageServiceMock(
            getPreviewImageDataProvider: { _, _, _ in
                XCTFail("Underlying service should not be called when the disk cache is warm.")
                return Data()
            }
        )
        let service = CachedJotFilePreviewImageService(
            localFileService: FileServiceMock(
                readFileProvider: { _ in cachedData }
            ),
            jotFilePreviewImageService: underlying
        )

        // When
        let data = try await service.getPreviewImageData(
            jotFileInfo: info,
            userInterfaceStyle: .dark,
            displayScale: 3.0
        )

        // Then
        XCTAssertEqual(data, cachedData)
    }
}

final class LockIsolated<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value

    init(_ value: Value) { _value = value }

    var value: Value {
        lock.withLock { _value }
    }

    func withValue(_ work: (inout Value) -> Void) {
        lock.withLock { work(&_value) }
    }
}
