//
//  TextImageScanner.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import UIKit

import EdgeOCRSwift

extension UIImage {
    // MARK: - テキスト画像スキャン

    func scanTextImage() throws -> UIImage? {
        let edgeOCR = EdgeOCR.getInstance()

        let rotatedImage = self.fixImageRotation()

        // MARK: 画像全体をスキャンするための設定

        let scanOptions = ScanOptions(
            scanMode: ScanOptions.ScanMode.OneShot,
            cropRect: CropRect(
                horizontalBias: 0.5,
                verticalBias: 0.5,
                width: 1.0,
                height: 1.0))

        // MARK: - 画像からテキストを検出・認識

        let detections = try edgeOCR.scan(rotatedImage, scanOptions: scanOptions)

        // MARK: - バウンデイングボックスの座標を画像の絶対座標へ変換

        var boundingBoxes: [CGRect] = []
        var texts: [String] = []
        for detection in detections.getTextDetections() {
            let bbox = detection.getBoundingBox()
            let x = self.size.width * bbox.minX
            let y = self.size.height * bbox.minY
            let width = self.size.width * bbox.width
            let height = self.size.height * bbox.height
            let rect = CGRect(x: x, y: y, width: width, height: height)
            boundingBoxes.append(rect)
            texts.append(detection.getText())
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
