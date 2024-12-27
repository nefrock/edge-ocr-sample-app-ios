//
//  EditDistanceAnalyzer.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import EdgeOCRSwift
import Foundation
import os

class FuzzySearchAnalyzer {
    let candidates: [String] = [
        "東京都新宿区",
        "群馬県前橋市",
        "神奈川県横浜市",
        "大阪府中央区",
        "沖縄県那覇市",
        "北海道札幌市",
    ]
    let fuzzySearch = FuzzySearch(FuzzySearch.DistanceType.editDistance)

    init() {
        do {
            try fuzzySearch.loadWeight(FuzzySearch.WeightType.NNDistance)
            try fuzzySearch.loadMasterData(candidates)
        } catch {
            os_log("Failed to load weight or master data: %s", log: .default, type: .error, error.localizedDescription)
        }
    }

    func analyze(_ detections: [Text], minDist: Int) -> AnalyzerResult {
        var targetDetections = [Text]()
        var notTargetDetections = [Text]()

        for detection in detections {
            var targetDetection: Text? = nil
            let text = detection.getText()
            let ret = fuzzySearch.calcSimilarityWithMasterData(text, parallel: true, normalized: false)
            if let ret = ret {
                let (matched, dist) = ret
                if dist <= Double(minDist) {
                    detection.setText(matched)
                    targetDetection = detection
                }
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
