//
//  WhiteListViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/08.
//

import AVFoundation
import EdgeOCRSwift
import os
import SwiftUI
import UIKit

class WhiteListViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!
    var guideLayer: CALayer!

    // モデルのアスペクト比
    @Binding var aspectRatio: Double

    // 検出結果の表示用フラグとメッセージ
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    // MARK: - ホワイトリストアナライザーを初期化

    var analyzer = WhiteListAnalyzer()

    init(
        aspectRatio: Binding<Double>,
        showDialog: Binding<Bool>,
        messages: Binding<[String]>)
    {
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
        let width = previewBounds.width
        let height = previewBounds.width * CGFloat(aspectRatio)
        let defaultCropRect = CropRect()
        let coropHorizontalBias = defaultCropRect.horizontalBias
        let cropVerticalBias = defaultCropRect.verticalBias
        let cropWidth = defaultCropRect.width
        let cropHeight = defaultCropRect.height
        guideLayer = CALayer()
        guideLayer.frame = CGRect(
            x: coropHorizontalBias * (previewBounds.width - width),
            y: cropVerticalBias * (previewBounds.height - height),
            width: cropWidth * width,
            height: cropHeight * height)

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

    func drawDetection(
        bbox: CGRect,
        text: String,
        boxColor: CGColor = UIColor.green.withAlphaComponent(0.5).cgColor,
        textColor: CGColor = UIColor.black.cgColor)
    {
        let boxLayer = CALayer()

        // バウンディングボックスの座標を計算
        let width = detectionLayer.frame.width
        let height = detectionLayer.frame.height
        let bounds = CGRect(
            x: bbox.minX * width,
            y: bbox.minY * height,
            width: (bbox.maxX - bbox.minX) * width,
            height: (bbox.maxY - bbox.minY) * height)
        boxLayer.frame = bounds

        // バウンディングボックスに緑色の外枠を設定
        let borderWidth = 1.0
        boxLayer.borderWidth = borderWidth
        boxLayer.borderColor = boxColor

        // 認識結果のテキストを設定
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

    func drawDetections(result: ScanResult) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionLayer.sublayers = nil

        // MARK: - ホワイトリストに検出結果が含まれているかを判定

        let detections = result.getTextDetections()
        let analyzerResult = analyzer.analyze(detections)
        var messages: [String] = []
        for targetDetection in analyzerResult.getTargetDetections() {
            let text = targetDetection.getScanObject().getText()
            let bbox = targetDetection.getBoundingBox()
            drawDetection(bbox: bbox, text: text)
            messages.append(text)
        }

        for notTargetDetection in analyzerResult.getNotTargetDetections() {
            let text = notTargetDetection.getScanObject().getText()
            let bbox = notTargetDetection.getBoundingBox()
            drawDetection(bbox: bbox, text: text, boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
        }

        if messages.count > 0 {
            showDialog = true
            self.messages = messages
        }
        CATransaction.commit()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let scanResult: ScanResult
        do {
            scanResult = try edgeOCR.scanTexts(sampleBuffer, previewViewBounds: previewBounds)
        } catch {
            os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.drawDetections(result: scanResult)
        }
    }
}

struct HostedWhiteListViewController: UIViewControllerRepresentable {
    @Binding var aspectRatio: Double
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    func makeUIViewController(context: Context) -> WhiteListViewController {
        return WhiteListViewController(aspectRatio: $aspectRatio,
                                       showDialog: $showDialog,
                                       messages: $messages)
    }

    func updateUIViewController(_ uiViewController: WhiteListViewController, context: Context) {}
}

#Preview {
    HostedWhiteListViewController(
        aspectRatio: .constant(1.0),
        showDialog: .constant(false),
        messages: .constant(["090-1234-5678"]))
}
