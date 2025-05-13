//
//  loadModel.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/02/26.
//

import EdgeOCRCxx
import EdgeOCRSwift
import Foundation
import os

func loadModel(
    path: String,
    uid: String,
    modelSettings: EdgeOCRSwift.ModelSettings = ModelSettings(),
    experimental: Bool = false
) async throws -> ModelInformation? {
    let modelPath = Bundle.main.path(forResource: path, ofType: "")
    guard let modelPath = modelPath else {
        throw EdgeError.notFound(description: "Not found models at the given path: \(path)")
    }

    let edgeOCR = try ModelBuilder().fromPath(modelPath).build()
    var model: Model?
    let allModels = experimental ? edgeOCR.availableModelsWithExperimental() : edgeOCR.availableModels()
    for candidate in  allModels {
        os_log("model candidate: %@", candidate.getUID())
        if candidate.getUID() == uid {
            model = candidate
        }
    }

    guard let model = model else {
        throw EdgeError.notFound(description: "Not found \(uid) model")
    }

    let modelInfo = try await edgeOCR.useModel(model, settings: modelSettings)
    os_log("model: %@", type: .debug, "\(model)")
    return modelInfo
}
