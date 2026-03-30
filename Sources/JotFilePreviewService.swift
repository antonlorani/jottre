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

import Foundation
import PencilKit
import UIKit

protocol JotFilePreviewServiceProtocol: Sendable {

    func getPreviewImageData(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle
    ) async throws -> Data
}

struct JotFilePreviewService: Sendable {

    enum Constants {
        static let size = CGSize(width: 160, height: 160)
        static let compressionQuality = CGFloat(0.8)
    }

    enum Failure: Error {
        case couldNotRenderImage
    }

    private let fileService: JotFileServiceProtocol

    init(fileService: JotFileServiceProtocol) {
        self.fileService = fileService
    }

    func getPreviewImageData(
        jotFileInfo: JotFile.Info,
        userInterfaceStyle: UIUserInterfaceStyle
    ) async throws -> Data {
        let jotFile = try fileService.readJotFile(jotFileInfo: jotFileInfo)
        let drawing = try PKDrawing(data: jotFile.jot.drawing)

        let aspectRatio = Constants.size.width / Constants.size.height
        let rect = CGRect(
            x: .zero,
            y: .zero,
            width: jotFile.jot.width,
            height: jotFile.jot.width / aspectRatio
        )
        let scale = await UIScreen.main.scale * Constants.size.width / jotFile.jot.width

        let traitCollection = UITraitCollection(userInterfaceStyle: userInterfaceStyle)

        let image = await MainActor.run {
            var image: UIImage?
            traitCollection.performAsCurrent {
                image = drawing.image(from: rect, scale: scale)
            }
            return image
        }

        guard let imageData = image?.jpegData(compressionQuality: Constants.compressionQuality) else {
            throw Failure.couldNotRenderImage
        }

        return imageData
    }
}
