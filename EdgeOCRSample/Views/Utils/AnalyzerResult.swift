//
//  AnalyzerResult.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import EdgeOCRSwift
import Foundation

class AnalyzerResult {
    let targetDetections: [Detection]
    let notTargetDetections: [Detection]

    init(targetDetections: [Detection], notTargetDetections: [Detection]) {
        self.targetDetections = targetDetections
        self.notTargetDetections = notTargetDetections
    }

    func getTargetDetections() -> [Detection] {
        return targetDetections
    }

    func getNotTargetDetections() -> [Detection] {
        return notTargetDetections
    }
}
