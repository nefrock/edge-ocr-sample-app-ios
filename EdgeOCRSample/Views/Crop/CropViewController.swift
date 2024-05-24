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
    var scanOptions: ScanOptions

    init(
        scanOptions: ScanOptions)
    {
        self.scanOptions = scanOptions
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - 認識するレイヤーの初期化

    override func setupLayers() {
        // 検出範囲を示すガイドを設定
        let cropWidth = scanOptions.getCropRect().width
        let cropHeight = scanOptions.getCropRect().height
        let cropHorizontalBias = scanOptions.getCropRect().horizontalBias
        let cropVerticalBias = scanOptions.getCropRect().verticalBias

        let width = viewBounds.width * cropWidth
        let height = viewBounds.height * cropHeight

        guideLayer = CALayer()
        guideLayer.frame = CGRect(
            x: cropHorizontalBias * (viewBounds.width - width),
            y: cropVerticalBias * (viewBounds.height - height),
            width: width,
            height: height)
        let borderWidth = 3.0
        let boxColor = UIColor.green.cgColor
        guideLayer.borderWidth = borderWidth
        guideLayer.borderColor = boxColor

        // 検出結果を表示させるレイヤーを作成
        detectionLayer = CALayer()
        detectionLayer.frame = viewBounds

        DispatchQueue.main.async { [weak self] in
            if let layer = self?.previewLayer {
                layer.addSublayer(self!.detectionLayer)
                layer.addSublayer(self!.guideLayer)
            }
        }
    }

    // MARK: - 検出範囲を更新

    func updateDetectinLayer(
        scanOptions: ScanOptions)
    {
        // scanOptionを更新
        self.scanOptions = scanOptions

        // detectionLayerを更新
        let cropWidth = scanOptions.getCropRect().width
        let cropHeight = scanOptions.getCropRect().height
        let cropHorizontalBias = scanOptions.getCropRect().horizontalBias
        let cropVerticalBias = scanOptions.getCropRect().verticalBias

        guideLayer.frame =
            CGRect(
                x: cropHorizontalBias * (viewBounds.width - viewBounds.width * cropWidth),
                y: cropVerticalBias * (viewBounds.height - viewBounds.height * cropHeight),
                width: viewBounds.width * cropWidth,
                height: viewBounds.height * cropHeight)
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
            let text = detection.getText()
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

            scanResult = try edgeOCR.scan(
                sampleBuffer,
                scanOptions: scanOptions,
                viewBounds: viewBounds)

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
        let scanOptions = ScanOptions(
            scanMode: ScanOptions.ScanMode.Default,
            cropRect: CropRect(
                horizontalBias: $cropHorizontalBias.wrappedValue,
                verticalBias: $cropVerticalBias.wrappedValue,
                width: $cropWidth.wrappedValue,
                height: $cropHeight.wrappedValue))
        return CropViewController(
            scanOptions: scanOptions)
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {
        guard uiViewController.detectionLayer != nil else {
            return
        }
        let scanOptions = ScanOptions(
            scanMode: ScanOptions.ScanMode.Default,
            cropRect: CropRect(
                horizontalBias: $cropHorizontalBias.wrappedValue,
                verticalBias: $cropVerticalBias.wrappedValue,
                width: $cropWidth.wrappedValue,
                height: $cropHeight.wrappedValue))
        uiViewController.updateDetectinLayer(scanOptions: scanOptions)
    }
}

#Preview {
    HostedCropViewController(
        cropHorizontalBias: .constant(0.5),
        cropVerticalBias: .constant(0.5),
        cropWidth: .constant(1.0),
        cropHeight: .constant(1.0))
}
