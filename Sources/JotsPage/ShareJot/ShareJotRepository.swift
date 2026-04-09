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

    enum Failure: Error {
        case couldNotRenderImage
    }

    private let jotFileService: JotFileServiceProtocol

    init(jotFileService: JotFileServiceProtocol) {
        self.jotFileService = jotFileService
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

        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = jotFileInfo.name

        switch format {
        case .pdf:
            return try await exportPDF(
                drawing: drawing,
                rect: rect,
                url: tempDirectory.appendingPathComponent("\(fileName).pdf")
            )
        case .jpg:
            return try await exportJPG(
                drawing: drawing,
                rect: rect,
                url: tempDirectory.appendingPathComponent("\(fileName).jpg")
            )
        case .png:
            return try await exportPNG(
                drawing: drawing,
                rect: rect,
                url: tempDirectory.appendingPathComponent("\(fileName).png")
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
                let image = drawing.image(from: rect, scale: 2)
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
                drawing.image(from: rect, scale: 2).draw(in: rect)
            }
            guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
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
            let image = drawing.image(from: rect, scale: 2)
            guard let pngData = image.pngData() else {
                throw Failure.couldNotRenderImage
            }
            return pngData
        }
        try data.write(to: url)
        return url
    }
}
