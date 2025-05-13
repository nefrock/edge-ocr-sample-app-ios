//
//  BoxexOverlayViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/02/26.
//

import AVFoundation
import EdgeOCRSwift
import SwiftUI
import UIKit
import os

class BoxesOverlayViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!
    var guideLayer: CALayer!

    // モデルのアスペクト比
    @Binding var aspectRatio: Double

    init(aspectRatio: Binding<Double>) {
        _aspectRatio = aspectRatio
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - 認識するレイヤーの初期化

    override func setupLayers() {
        // 検出範囲を示すガイドを設定
        let width = viewBounds.width
        let height = viewBounds.width * CGFloat(aspectRatio)
        // デフォルトの検出領域である画面中央にガイドを表示
        let cropHorizontalBias = 0.5
        let cropVerticalBias = 0.5
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

    // MARK: - バウンディングボックスの描画

    func drawDetection(
        bbox: CGRect,
        text: String,
        boxColor: CGColor = UIColor.green.withAlphaComponent(0.5).cgColor,
        textColor: CGColor = UIColor.black.cgColor
    ) {
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
        for detection in result.getTextDetections() {
            let text = detection.getText()
            if !text.isEmpty {
                let bbox = detection.getBoundingBox()
                drawDetection(bbox: bbox, text: text)
            }
        }
        CATransaction.commit()
    }

    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
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

struct HostedBoxesOverlayViewController: UIViewControllerRepresentable {
    @Binding var aspectRatio: Double
    func makeUIViewController(context: Context) -> BoxesOverlayViewController {
        return BoxesOverlayViewController(aspectRatio: $aspectRatio)
    }

    func updateUIViewController(_ uiViewController: BoxesOverlayViewController, context: Context) {}
}

#Preview {
    HostedBoxesOverlayViewController(aspectRatio: .constant(1.0))
}
