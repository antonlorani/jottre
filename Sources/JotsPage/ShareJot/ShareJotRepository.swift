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

@preconcurrency import PencilKit
import UIKit

protocol ShareJotRepositoryProtocol: Sendable {

    func exportJot(
        jotFileInfo: JotFile.Info,
        format: ShareFormat
    ) async throws -> URL
}

struct ShareJotRepository: ShareJotRepositoryProtocol {

    private enum Constants {

        enum Rendering {
            static let scale = CGFloat(2)
        }

        enum JpegEncoding {
            static let compressionQuality = CGFloat(0.9)
        }
    }

    enum Failure: Error {
        case couldNotRenderImage
    }

    private let jotFileService: JotFileServiceProtocol
    private let fileService: FileServiceProtocol

    init(
        jotFileService: JotFileServiceProtocol,
        fileService: FileServiceProtocol
    ) {
        self.jotFileService = jotFileService
        self.fileService = fileService
    }

    func exportJot(
        jotFileInfo: JotFile.Info,
        format: ShareFormat
    ) async throws -> URL {
        let jotFile = try jotFileService.readJotFile(jotFileInfo: jotFileInfo)
        let drawing = try PKDrawing(data: jotFile.jot.drawing)

        let width = jotFile.jot.width
        let contentHeight = max(drawing.bounds.maxY, width * sqrt(2))
        let rect = CGRect(x: 0, y: 0, width: width, height: contentHeight)

        let temporaryDirectory = fileService.temporaryDirectory()
        let fileName = jotFileInfo.name

        switch format {
        case .pdf:
            return try await exportPDF(
                drawing: drawing,
                rect: rect,
                url: temporaryDirectory.appendingPathComponent("\(fileName).pdf")
            )
        case .jpg:
            return try await exportJPG(
                drawing: drawing,
                rect: rect,
                url: temporaryDirectory.appendingPathComponent("\(fileName).jpg")
            )
        case .png:
            return try await exportPNG(
                drawing: drawing,
                rect: rect,
                url: temporaryDirectory.appendingPathComponent("\(fileName).png")
            )
        }
    }

    private func exportPDF(
        drawing: PKDrawing,
        rect: CGRect,
        url: URL
    ) async throws -> URL {
        let data = await MainActor.run {
            let renderer = UIGraphicsPDFRenderer(bounds: rect)
            return renderer.pdfData { context in
                context.beginPage()
                let image = renderDrawing(drawing: drawing, rect: rect)
                image.draw(in: rect)
            }
        }
        try data.write(to: url)
        return url
    }

    private func exportJPG(
        drawing: PKDrawing,
        rect: CGRect,
        url: URL
    ) async throws -> URL {
        let data: Data = try await MainActor.run {
            let renderer = UIGraphicsImageRenderer(bounds: rect)
            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(rect)
                renderDrawing(drawing: drawing, rect: rect).draw(in: rect)
            }
            guard let jpegData = image.jpegData(compressionQuality: Constants.JpegEncoding.compressionQuality) else {
                throw Failure.couldNotRenderImage
            }
            return jpegData
        }
        try data.write(to: url)
        return url
    }

    private func exportPNG(
        drawing: PKDrawing,
        rect: CGRect,
        url: URL
    ) async throws -> URL {
        let data: Data = try await MainActor.run {
            let image = renderDrawing(drawing: drawing, rect: rect)
            guard let pngData = image.pngData() else {
                throw Failure.couldNotRenderImage
            }
            return pngData
        }
        try data.write(to: url)
        return url
    }

    @MainActor
    private func renderDrawing(drawing: PKDrawing, rect: CGRect) -> UIImage {
        var image = UIImage()
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            image = drawing.image(from: rect, scale: Constants.Rendering.scale)
        }
        return image
    }
}
