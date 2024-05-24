//
//  CenterDetectionFilter.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//
//
import EdgeOCRSwift
import Foundation

// MARK: - 中心に最も近いテキストのみを認識する

class CenterDetectionFilter: DetectionFilter {
    override func filter(_ detections: [Detection]) -> [Detection] {
        var filteredDetections: [Detection] = []
        if detections.count > 0 {
            var mostCenteredBox = detections[0]
            var distanceFromCenter = 100.0
            for detection in detections {
                let dist = self.calcDistanceFromCenter(detection: detection)
                if dist < distanceFromCenter {
                    distanceFromCenter = dist
                    mostCenteredBox = detection
                }
            }
            filteredDetections.append(mostCenteredBox)
        }
        return filteredDetections
    }

    private func calcDistanceFromCenter(detection: Detection) -> CGFloat {
        let bbox = detection.getBoundingBox()
        let top = bbox.minY
        let left = bbox.minX
        let bottom = bbox.maxY
        let right = bbox.maxX
        let boxCenterX = left + 0.5 * (right - left)
        let boxCenterY = top + 0.5 * (bottom - top)

        let a = 0.5 - boxCenterX
        let b = 0.5 - boxCenterY
        return a * a + b * b
    }
}
