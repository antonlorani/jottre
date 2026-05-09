/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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

    func test_getPreviewImageData_givenColdCache_writesThroughToDiskCache() async throws {
        // Given
        let writeFileExpectation = XCTestExpectation(description: "FileServiceMock.writeFileProvider is called.")
        let producedData = Data([4, 5, 6])
        let writtenURL = LockIsolated<URL?>(nil)
        let writtenData = LockIsolated<Data?>(nil)
        let service = CachedJotFilePreviewImageService(
            localFileService: FileServiceMock(
                temporaryDirectoryProvider: {
                    FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString, isDirectory: true)
                },
                readFileProvider: { _ in throw NSError(domain: "noDiskCache", code: 0) },
                writeFileProvider: { receivedURL, receivedData in
                    writtenURL.withValue { $0 = receivedURL }
                    writtenData.withValue { $0 = receivedData }
                    writeFileExpectation.fulfill()
                }
            ),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(
                getPreviewImageDataProvider: { _, _, _ in producedData }
            )
        )

        // When
        let data = try await service.getPreviewImageData(
            jotFileInfo: info,
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        XCTAssertEqual(data, producedData)
        await fulfillment(of: [writeFileExpectation], timeout: 0.5)
        XCTAssertEqual(writtenData.value, producedData)
        XCTAssertNotNil(writtenURL.value)
    }

    func test_getPreviewImageData_givenJotFileInfoWithoutModificationDate_skipsDiskCache() async throws {
        // Given
        let readFileExpectation = XCTestExpectation(description: "FileServiceMock.readFileProvider is not called.")
        readFileExpectation.isInverted = true
        let writeFileExpectation = XCTestExpectation(description: "FileServiceMock.writeFileProvider is not called.")
        writeFileExpectation.isInverted = true
        let undatedInfo = JotFile.Info(
            url: URL(staticString: "file:///tmp/note.jot"),
            name: "note",
            modificationDate: nil,
            ubiquitousInfo: nil
        )
        let service = CachedJotFilePreviewImageService(
            localFileService: FileServiceMock(
                readFileProvider: { _ in
                    readFileExpectation.fulfill()
                    return Data()
                },
                writeFileProvider: { _, _ in writeFileExpectation.fulfill() }
            ),
            jotFilePreviewImageService: JotFilePreviewImageServiceMock(
                getPreviewImageDataProvider: { _, _, _ in Data([1]) }
            )
        )

        // When
        _ = try await service.getPreviewImageData(
            jotFileInfo: undatedInfo,
            userInterfaceStyle: .light,
            displayScale: 2.0
        )

        // Then
        await fulfillment(of: [readFileExpectation, writeFileExpectation], timeout: 0.2)
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
