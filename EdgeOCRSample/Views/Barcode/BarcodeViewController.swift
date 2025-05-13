//
//  BarcodeViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import AVFoundation
import EdgeOCRSwift
import RegexBuilder
import SwiftUI
import UIKit
import os

class BarcodeViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!
    var guideLayer: CALayer!

    // モデルのアスペクト比
    @Binding var aspectRatio: Double
    // 検出結果の表示用フラグとメッセージ
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    // MARK: - バーコードスキャンオプション

    private let scanOptions = ScanOptions(targetFormats: [BarcodeFormat.AnyFormat])

    init(
        aspectRatio: Binding<Double>,
        showDialog: Binding<Bool>,
        messages: Binding<[String]>
    ) {
        _aspectRatio = aspectRatio
        _showDialog = showDialog
        _messages = messages
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupLayers() {
        // 検出範囲を示すガイドを設定
        let width = viewBounds.width
        let height = viewBounds.height
        // デフォルトの検出領域である画面中央にガイドを表示
        let cropHorizontalBias = 0.5
        let cropVerticalBias = 0.5
        guideLayer = CALayer()
        guideLayer.frame = CGRect(
            x: cropHorizontalBias * (viewBounds.width - width),
            y: cropVerticalBias * (viewBounds.height - height),
            width: width,
            height: height)
        print(viewBounds.width, viewBounds.height, width, height)

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

    func drawDetection(
        bbox: CGRect,
        text: String,
        boxColor: CGColor = UIColor.green.withAlphaComponent(0.5).cgColor,
        textColor: CGColor = UIColor.black.cgColor
    ) {
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
        boxLayer.borderWidth = borderWidth
        boxLayer.borderColor = boxColor

        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.fontSize = 15
        textLayer.frame = CGRect(
            x: 0, y: -20,
            width: boxLayer.frame.width,
            height: 20)
        textLayer.backgroundColor = boxColor
        textLayer.foregroundColor = textColor

        boxLayer.addSublayer(textLayer)
        detectionLayer.addSublayer(boxLayer)
    }

    func showDialog(detections: [Barcode]) {
        var messages: [String] = []
        for detection in detections {
            messages.append(detection.getText())
        }
        self.messages = messages
        showDialog = true

        // MARK: - バーコードのスキャン状況をリセット

        edgeOCR.resetScanningState()
    }

    func drawDetections(result: ScanResult) {
        var detections: [Barcode] = []

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionLayer.sublayers = nil
        for detection in result.getBarcodeDetections() {
            if detection.getStatus() == ScanConfirmationStatus.Confirmed {
                let bbox = detection.getBoundingBox()
                drawDetection(bbox: bbox, text: detection.getText())
                detections.append(detection)
            }
        }
        CATransaction.commit()

        if detections.count > 0 && !showDialog {
            showDialog(detections: detections)
        }
    }

    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let scanResult: ScanResult
        do {
            // MARK: - バーコードの読み取り

            scanResult = try edgeOCR.scan(
                sampleBuffer, scanOptions: scanOptions, viewBounds: viewBounds)

        } catch {
            os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.drawDetections(result: scanResult)
        }
    }
}

struct HostedBarcodeViewController: UIViewControllerRepresentable {
    @Binding var aspectRatio: Double
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    func makeUIViewController(context: Context) -> BarcodeViewController {
        return BarcodeViewController(
            aspectRatio: $aspectRatio,
            showDialog: $showDialog,
            messages: $messages)
    }

    func updateUIViewController(_ uiViewController: BarcodeViewController, context: Context) {}
}

#Preview {
    HostedBarcodeViewController(
        aspectRatio: .constant(1.0),
        showDialog: .constant(false),
        messages: .constant(["9000102"]))
}
