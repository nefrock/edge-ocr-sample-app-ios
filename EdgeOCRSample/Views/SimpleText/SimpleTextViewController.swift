//
//  SimpleTextView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/02/26.
//

import AVFoundation
import EdgeOCRSwift
import os
import SwiftUI
import UIKit

class SimpleTextViewController: ViewController {
    private let edgeOCR = EdgeOCR.getInstance()

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        do {
            let scanResult = try edgeOCR.scan(sampleBuffer, viewBounds: viewBounds)
            for detection in scanResult.getDetections() {
                let text = detection.getText()
                if !text.isEmpty {
                    os_log("detected: %@", type: .debug, text)
                }
            }
        } catch {
            os_log("Failed to scan texts: %@", type: .error, error.localizedDescription)
            return
        }
    }
}

struct HostedSimpleTextViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return SimpleTextViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    HostedSimpleTextViewController()
}
