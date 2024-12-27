//
//  EditDistanceAnalyzer.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import EdgeOCRSwift
import Foundation
import os

class FuzzyRegexAnalyzer {
    let fuzzyRegex = FuzzyRegex(pattern: #"[0-9]+-[0-9]+"#, fuzzyType: .NNDistance, threshold: 0.4)
    init() {}

    func analyze(_ detections: [Text]) -> AnalyzerResult {
        var targetDetections = [Text]()
        var notTargetDetections = [Text]()

        for detection in detections {
            var targetDetection: Text? = nil
            let text = detection.getText()
            let matched = fuzzyRegex.match(text)
            if !matched.isEmpty {
                detection.setText(matched)
                targetDetection = detection
            }
            if let targetDetection = targetDetection {
                targetDetections.append(targetDetection)
            } else {
                notTargetDetections.append(detection)
            }
        }

        return AnalyzerResult(
            targetDetections: targetDetections,
            notTargetDetections: notTargetDetections)
    }
}
