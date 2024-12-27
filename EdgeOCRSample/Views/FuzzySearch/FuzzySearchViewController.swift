//
//  EditDistanceView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import AVFoundation
import EdgeOCRSwift
import os
import SwiftUI
import UIKit

class FuzzySearchViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!
    var guideLayer: CALayer!

    // モデルのアスペクト比
    @Binding var aspectRatio: Double

    // 検出結果の表示用フラグとメッセージ
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    // MARK: - 編集距離アナライザーを初期化

    var analyzer = FuzzySearchAnalyzer()

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
        let width = viewBounds.width
        let height = viewBounds.width * CGFloat(aspectRatio)
        // デフォルトの検出領域である画面中央にガイドを表示
        let coropHorizontalBias = 0.5
        let cropVerticalBias = 0.5
        guideLayer = CALayer()
        guideLayer.frame = CGRect(
            x: coropHorizontalBias * (viewBounds.width - width),
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

        // MARK: - 編集距離を許容して，ホワイトリストに検出結果が含まれているかを判定

        let detections = result.getTextDetections()
        let minDist = 1
        let analyzerResult = analyzer.analyze(detections, minDist: minDist)
        var messages: [String] = []
        for targetDetection in analyzerResult.getTargetDetections() {
            let text = targetDetection.getText()
            let bbox = targetDetection.getBoundingBox()
            drawDetection(bbox: bbox, text: text)
            messages.append(text)
        }

        for notTargetDetection in analyzerResult.getNotTargetDetections() {
            let text = notTargetDetection.getText()
            let bbox = notTargetDetection.getBoundingBox()
            drawDetection(bbox: bbox,
                          text: text,
                          boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
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
            scanResult = try edgeOCR.scan(sampleBuffer, viewBounds: viewBounds)
        } catch {
            os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.drawDetections(result: scanResult)
        }
    }
}

struct HostedFuzzySearchViewController: UIViewControllerRepresentable {
    @Binding var aspectRatio: Double
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    func makeUIViewController(context: Context) -> FuzzySearchViewController {
        return FuzzySearchViewController(aspectRatio: $aspectRatio,
                                         showDialog: $showDialog,
                                         messages: $messages)
    }

    func updateUIViewController(_ uiViewController: FuzzySearchViewController, context: Context) {}
}

#Preview {
    HostedFuzzySearchViewController(
        aspectRatio: .constant(1.0),
        showDialog: .constant(false),
        messages: .constant(["東京都新宿区"]))
}
