import UIKit
import XCTest

@testable import Jottre

final class SettingsRepositoryTests: XCTestCase {

    func test_shouldShowEnableICloudButton_givenUbiquitousServiceDisabled_returnsTrue() {
        // Given
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { false }),
            bundleService: BundleServiceMock(),
            defaultsService: DefaultsServiceMock()
        )

        // Then
        XCTAssertTrue(repository.shouldShowEnableICloudButton())
    }

    func test_shouldShowEnableICloudButton_givenUbiquitousServiceEnabled_returnsFalse() {
        // Given
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(isEnabledProvider: { true }),
            bundleService: BundleServiceMock(),
            defaultsService: DefaultsServiceMock()
        )

        // Then
        XCTAssertFalse(repository.shouldShowEnableICloudButton())
    }

    func test_appVersion_givenBundleProvidesValue_returnsValue() {
        // Given
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(),
            bundleService: BundleServiceMock(shortVersionStringProvider: { "1.2.3" }),
            defaultsService: DefaultsServiceMock()
        )

        // Then
        XCTAssertEqual(repository.appVersion(), "1.2.3")
    }

    func test_appVersion_givenBundleReturnsNil_returnsDash() {
        // Given
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(),
            bundleService: BundleServiceMock(shortVersionStringProvider: { nil }),
            defaultsService: DefaultsServiceMock()
        )

        // Then
        XCTAssertEqual(repository.appVersion(), "-")
    }

    func test_userInterfaceStyle_givenStoredRawValue_emitsMatchingStyle() async throws {
        // Given
        let defaultsServiceMock = DefaultsServiceMock(
            initialValues: [DefaultsKey<Int>.userInterfaceStyle.description: UIUserInterfaceStyle.dark.rawValue]
        )
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(),
            bundleService: BundleServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // When
        var iterator = repository.userInterfaceStyle().makeAsyncIterator()
        let first = try await XCTUnwrapAsync(await iterator.next())

        // Then
        XCTAssertEqual(first, .dark)
    }

    func test_userInterfaceStyle_givenNoStoredValue_emitsUnspecified() async throws {
        // Given
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(),
            bundleService: BundleServiceMock(),
            defaultsService: DefaultsServiceMock()
        )

        // When
        var iterator = repository.userInterfaceStyle().makeAsyncIterator()
        let first = try await XCTUnwrapAsync(await iterator.next())

        // Then
        XCTAssertEqual(first, .unspecified)
    }

    func test_updateUserInterfaceStyle_persistsRawValueInDefaults() {
        // Given
        let defaultsServiceMock = DefaultsServiceMock()
        let repository = SettingsRepository(
            ubiquitousFileService: FileServiceMock(),
            bundleService: BundleServiceMock(),
            defaultsService: defaultsServiceMock
        )

        // When
        repository.updateUserInterfaceStyle(.light)

        // Then
        XCTAssertEqual(defaultsServiceMock.getValue(.userInterfaceStyle), UIUserInterfaceStyle.light.rawValue)
    }
}

private func XCTUnwrapAsync<T>(
    _ expression: @autoclosure () async throws -> T?,
    file: StaticString = #filePath,
    line: UInt = #line
) async throws -> T {
    let value = try await expression()
    return try XCTUnwrap(value, file: file, line: line)
}
