//
//  CropViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/12.
//

import AVFoundation
import EdgeOCRSwift
import os
import SwiftUI
import UIKit

class CropViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!
    var guideLayer: CALayer!

    // 切り取る領域の設定
    var scanOption: ScanOption

    init(
        scanOption: ScanOption)
    {
        self.scanOption = scanOption
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - 認識するレイヤーの初期化

    override func setupLayers() {
        // 検出範囲を示すガイドを設定
        let cropWidth = scanOption.getCropRect().width
        let cropHeight = scanOption.getCropRect().height
        let cropHorizontalBias = scanOption.getCropRect().horizontalBias
        let cropVerticalBias = scanOption.getCropRect().verticalBias

        let width = previewBounds.width * cropWidth
        let height = previewBounds.height * cropHeight

        guideLayer = CALayer()
        guideLayer.frame = CGRect(
            x: cropHorizontalBias * (previewBounds.width - width),
            y: cropVerticalBias * (previewBounds.height - height),
            width: width,
            height: height)
        let borderWidth = 3.0
        let boxColor = UIColor.green.cgColor
        guideLayer.borderWidth = borderWidth
        guideLayer.borderColor = boxColor

        // 検出結果を表示させるレイヤーを作成
        detectionLayer = CALayer()
        detectionLayer.frame = previewBounds

        DispatchQueue.main.async { [weak self] in
            if let layer = self?.previewLayer {
                layer.addSublayer(self!.detectionLayer)
                layer.addSublayer(self!.guideLayer)
            }
        }
    }

    // MARK: - 検出範囲を更新

    func updateDetectinLayer(
        scanOption: ScanOption)
    {
        // scanOptionを更新
        self.scanOption = scanOption

        // detectionLayerを更新
        let cropWidth = scanOption.getCropRect().width
        let cropHeight = scanOption.getCropRect().height
        let cropHorizontalBias = scanOption.getCropRect().horizontalBias
        let cropVerticalBias = scanOption.getCropRect().verticalBias

        guideLayer.frame =
            CGRect(
                x: cropHorizontalBias * (previewBounds.width - previewBounds.width * cropWidth),
                y: cropVerticalBias * (previewBounds.height - previewBounds.height * cropHeight),
                width: previewBounds.width * cropWidth,
                height: previewBounds.height * cropHeight)
    }

    func drawDetection(
        bbox: CGRect,
        text: String,
        boxColor: CGColor = UIColor.green.withAlphaComponent(0.5).cgColor,
        textColor: CGColor = UIColor.black.cgColor)
    {
        let boxLayer = CALayer()
        let width = detectionLayer.frame.width
        let height = detectionLayer.frame.height
        let bounds = CGRect(
            x: bbox.minX * width,
            y: bbox.minY * height,
            width: (bbox.maxX - bbox.minX) * width,
            height: (bbox.maxY - bbox.minY) * height)
        boxLayer.frame = bounds

        let borderWidth = 1.0
        let boxColor = UIColor.green.cgColor
        boxLayer.borderWidth = borderWidth
        boxLayer.borderColor = boxColor

        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.fontSize = 15
        textLayer.frame = CGRect(
            x: 0,
            y: -20,
            width: boxLayer.frame.width,
            height: 20)
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.backgroundColor =
            UIColor.green.withAlphaComponent(0.5).cgColor

        boxLayer.addSublayer(textLayer)
        detectionLayer.addSublayer(boxLayer)
    }

    func drawDetections(result: ScanResult) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionLayer.sublayers = nil
        for detection in result.getTextDetections() {
            let text = detection.getScanObject().getText()
            if true {
                let bbox = detection.getBoundingBox()
                drawDetection(bbox: bbox, text: text)
            }
        }
        CATransaction.commit()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let scanResult: ScanResult
        do {
            // MARK: - scanOptionを指定して，OCRを実行

            scanResult = try edgeOCR.scanTexts(
                sampleBuffer,
                scanOption: scanOption,
                previewViewBounds: previewBounds)

        } catch {
            os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.drawDetections(result: scanResult)
        }
    }
}

struct HostedCropViewController: UIViewControllerRepresentable {
    // for crop area
    @Binding var cropHorizontalBias: CGFloat
    @Binding var cropVerticalBias: CGFloat
    @Binding var cropWidth: CGFloat
    @Binding var cropHeight: CGFloat

    func makeUIViewController(context: Context) -> CropViewController {
        let scanOption = ScanOption(
            scanMode: ScanOption.ScanMode.ScanModeTexts,
            cropRect: CropRect(
                horizontalBias: $cropHorizontalBias.wrappedValue,
                verticalBias: $cropVerticalBias.wrappedValue,
                width: $cropWidth.wrappedValue,
                height: $cropHeight.wrappedValue))
        return CropViewController(
            scanOption: scanOption)
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        guard uiViewController.detectionLayer != nil else {
            return
        }
        let scanOption = ScanOption(
            scanMode: ScanOption.ScanMode.ScanModeTexts,
            cropRect: CropRect(
                horizontalBias: $cropHorizontalBias.wrappedValue,
                verticalBias: $cropVerticalBias.wrappedValue,
                width: $cropWidth.wrappedValue,
                height: $cropHeight.wrappedValue))
        uiViewController.updateDetectinLayer(scanOption: scanOption)
    }
}

#Preview {
    HostedCropViewController(
        cropHorizontalBias: .constant(0.5),
        cropVerticalBias: .constant(0.5),
        cropWidth: .constant(1.0),
        cropHeight: .constant(1.0))
}
