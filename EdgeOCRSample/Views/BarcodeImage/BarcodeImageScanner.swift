//
//  BarcodeImageScanner.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import EdgeOCRSwift
import Foundation
import SwiftUI

extension UIImage {
    // MARK: - バーコード画像スキャン

    func scanBarcodeImage() throws -> UIImage? {
        let edgeOCR = EdgeOCR.getInstance()

        let rotatedImage = self.fixImageRotation()

        // MARK: - 画像からバーコードを検出・認識

        let barcodeScanOption = ScanOptions(scanMode: ScanOptions.ScanMode.OneShot,
                                            targetFormats: [BarcodeFormat.AnyFormat])
        let detections = try edgeOCR.scan(rotatedImage, scanOptions: barcodeScanOption)

        // MARK: - バウンデイングボックスの座標を画像の絶対座標へ変換

        var boundingBoxes: [CGRect] = []
        var texts: [String] = []
        for barcode in detections.getBarcodeDetections() {
            let bbox = barcode.getBoundingBox()
            let x = self.size.width * bbox.minX
            let y = self.size.height * bbox.minY
            let width = self.size.width * bbox.width
            let height = self.size.height * bbox.height
            let rect = CGRect(x: x, y: y, width: width, height: height)
            boundingBoxes.append(rect)
            texts.append(barcode.getText())
        }

        // MARK: - 検出・認識結果を画像に反映させた新しい画像を生成

        let imagesWithBbox =
            self.drawBoundingBoxes(
                boundingBoxes: boundingBoxes,
                texts: texts,
                textColor: UIColor.black,
                boxColor: UIColor.green.withAlphaComponent(0.5))

        return imagesWithBbox
    }
}
