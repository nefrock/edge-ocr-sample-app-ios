//
//  FeedbackViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import AVFoundation
import EdgeOCRSwift
import os
import SwiftUI
import UIKit

class FeedbackViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()
    var detectionLayer: CALayer!

    // 送信フラグ
    @Binding var sendFlag: Bool

    init(sendFlag: Binding<Bool>) {
        _sendFlag = sendFlag
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // MARK: - フィードバックの送信

        if sendFlag {
            do {
                let _ = try edgeOCR.reportImage(
                    sampleBuffer,
                    userMessage: "",
                    previewViewBounds: previewBounds)
                Task { @MainActor in
                    sendFlag = false
                }
            } catch {
                os_log("Failed to scan texts: %@", type: .debug, error.localizedDescription)
                return
            }
        }
    }
}

struct HostedFeedbackViewController: UIViewControllerRepresentable {
    @Binding var sendFlag: Bool
    func makeUIViewController(context: Context) -> FeedbackViewController {
        return FeedbackViewController(sendFlag: $sendFlag)
    }

    func updateUIViewController(_ uiViewController: FeedbackViewController, context: Context) {}
}

#Preview {
    FeedbackViewController(sendFlag: .constant(false))
}
