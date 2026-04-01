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

import CryptoKit
import UIKit

actor CachedJotFilePreviewImageService: JotFilePreviewImageServiceProtocol {

    private enum Constants {
        static let diskCacheDirectoryName = "JotFilePreviewCache"
        static let memoryCacheSizeLimit = 20 * 1024 * 1024  // 20 MB
    }

    private struct CacheKey: CustomStringConvertible {
        let jotFilePath: String
        let modificationDate: Date?
        let userInterfaceStyle: UIUserInterfaceStyle
        let displayScale: CGFloat

        var description: String {
            [
                jotFilePath.description,
                modificationDate.map(\.timeIntervalSince1970.description),
                userInterfaceStyle.rawValue.description,
                displayScale.description,
            ]
            .compactMap { $0 }
            .joined(separator: "|")
        }
    }

    private let localFileService: FileServiceProtocol
    private let jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    private let memoryCache: NSCache<NSString, NSData>
    private let temporaryDirectory: URL

    init(
        localFileService: FileServiceProtocol,
        jotFilePreviewImageService: JotFilePreviewImageServiceProtocol
    ) {
        self.localFileService = localFileService
        self.jotFilePreviewImageService = jotFilePreviewImageService

        let cache = NSCache<NSString, NSData>()
        cache.totalCostLimit = Constants.memoryCacheSizeLimit
        self.memoryCache = cache

        temporaryDirectory =
            localFileService
            .temporaryDirectory()
            .appendingPathComponent(Constants.diskCacheDirectoryName, isDirectory: true)

        try? FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )
    }

    func getPreviewImageData(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) async throws -> Data {
        let memoryCacheKey = makeMemoryCacheKey(
            jotFileInfo: jotFileInfo,
            userInterfaceStyle: userInterfaceStyle,
            displayScale: displayScale
        )

        if let cached = memoryCache.object(forKey: memoryCacheKey) {
            return cached as Data
        }

        let diskCacheFileURL = makeDiskCacheFileURL(
            jotFileInfo: jotFileInfo,
            userInterfaceStyle: userInterfaceStyle,
            displayScale: displayScale
        )

        if let diskCacheFileURL,
            let cachedPreviewImageData = try? localFileService.readFile(fileURL: diskCacheFileURL)
        {
            memoryCache.setObject(
                cachedPreviewImageData as NSData,
                forKey: memoryCacheKey,
                cost: cachedPreviewImageData.count
            )
            return cachedPreviewImageData
        }

        let previewImageData = try await jotFilePreviewImageService.getPreviewImageData(
            jotFileInfo: jotFileInfo,
            userInterfaceStyle: userInterfaceStyle,
            displayScale: displayScale
        )

        memoryCache.setObject(
            previewImageData as NSData,
            forKey: memoryCacheKey,
            cost: previewImageData.count
        )

        if let diskCacheFileURL {
            try? localFileService.writeFile(fileURL: diskCacheFileURL, data: previewImageData)
        }

        return previewImageData
    }

    private func makeMemoryCacheKey(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) -> NSString {
        makeCacheKey(
            jotFilePath: jotFileInfo.url.path,
            modificationDate: jotFileInfo.modificationDate,
            userInterfaceStyle: userInterfaceStyle,
            displayScale: displayScale
        ) as NSString
    }

    private func makeDiskCacheFileURL(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) -> URL? {
        guard let modificationDate = jotFileInfo.modificationDate else {
            return nil
        }

        let cacheKey = makeCacheKey(
            jotFilePath: jotFileInfo.url.path,
            modificationDate: modificationDate,
            userInterfaceStyle: userInterfaceStyle,
            displayScale: displayScale
        )

        return temporaryDirectory.appendingPathComponent(cacheKey, isDirectory: false)
    }

    private func makeCacheKey(
        jotFilePath: String,
        modificationDate: Date?,
        userInterfaceStyle: UIUserInterfaceStyle,
        displayScale: CGFloat
    ) -> String {
        SHA256.hash(
            data: Data(
                CacheKey(
                    jotFilePath: jotFilePath,
                    modificationDate: modificationDate,
                    userInterfaceStyle: userInterfaceStyle,
                    displayScale: displayScale
                ).description.utf8
            )
        )
        .map { String(format: "%02x", $0) }
        .joined()
    }
}
