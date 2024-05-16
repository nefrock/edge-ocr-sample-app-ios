//
//  AnalyzerResult.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import EdgeOCRSwift
import Foundation

class AnalyzerResult {
    let targetDetections: [Detection<Text>]
    let notTargetDetections: [Detection<Text>]

    init(targetDetections: [Detection<Text>], notTargetDetections: [Detection<Text>]) {
        self.targetDetections = targetDetections
        self.notTargetDetections = notTargetDetections
    }

    func getTargetDetections() -> [Detection<Text>] {
        return targetDetections
    }

    func getNotTargetDetections() -> [Detection<Text>] {
        return notTargetDetections
    }
}
