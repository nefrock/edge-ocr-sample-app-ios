//
//  EditDistanceAnalyzer.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import EdgeOCRSwift
import Foundation

class EditDistanceAnalyzer {
    let candidates: Set = [
        "東京都新宿区",
        "群馬県前橋市",
        "神奈川県横浜市",
        "大阪府中央区",
        "沖縄県那覇市",
        "北海道札幌市",
    ]

    init() {}

    // 二つの文字列の編集距離を計算
    private static func editDistance(_ s0: String, s1: String) -> Int {
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s1.count + 1), count: s0.count + 1)
        for i in 0...s0.count {
            matrix[i][0] = i
        }
        for j in 0...s1.count {
            matrix[0][j] = j
        }
        for i in 1...s0.count {
            for j in 1...s1.count {
                let cost = s0[s0.index(s0.startIndex, offsetBy: i - 1)] == s1[s1.index(s1.startIndex, offsetBy: j - 1)] ? 0 : 1
                matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            }
        }
        return matrix[s0.count][s1.count]
    }

    func analyze(_ detections: [Detection<Text>], minDist: Int) -> AnalyzerResult {
        var targetDetections = [Detection<Text>]()
        var notTargetDetections = [Detection<Text>]()

        for detection in detections {
            var targetDetection: Detection<Text>? = nil
            for candidate in candidates {
                var obj = detection.getScanObject()
                let text = obj.getText()
                var dist = minDist + 1
                if !text.isEmpty {
                    dist = EditDistanceAnalyzer.editDistance(text, s1: candidate)
                }
                if dist <= minDist {
                    obj.setText(candidate)
                    detection.setScanObject(obj)
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
