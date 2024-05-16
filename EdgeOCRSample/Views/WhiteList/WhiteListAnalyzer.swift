//
//  DetectionWhiteListAnalyzer.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/08.
//

import EdgeOCRSwift
import Foundation

class WhiteListAnalyzer {
    let whiteList: Set = [
        "090-1234-5678",
        "090-0000-1234",
        "090-2222-3456",
        "090-4444-5555",
        "090-6666-7777",
        "090-8888-9999",
    ]

    init() {}

    func analyze(_ detections: [Detection<Text>]) -> AnalyzerResult {
        var targetDetections: [Detection<Text>] = []
        var notTargetDetections: [Detection<Text>] = []

        for detection in detections {
            let text = detection.getScanObject().getText()
            // ホワイトリストに含まれているかどうかを判定
            if whiteList.contains(text) {
                targetDetections.append(detection)
            } else {
                notTargetDetections.append(detection)
            }
        }

        return AnalyzerResult(
            targetDetections: targetDetections,
            notTargetDetections: notTargetDetections)
    }
}
