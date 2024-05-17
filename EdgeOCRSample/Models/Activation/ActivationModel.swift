//
//  Activation.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/02/26.
//

import EdgeOCRSwift
import Foundation

// MARK: - アクティベーション

func activate(key: String) async -> String? {
    let licenseAPI: NefrockLicenseAPI
    do {
        licenseAPI = try LicenseBuilder().withLicenseKey(key).build()
    } catch {
        return error.localizedDescription
    }

    do {
        _ = try await licenseAPI.isActivated()
    } catch {
        do {
            _ = try await licenseAPI.activate()
        } catch {
            return error.localizedDescription
        }
    }

    return nil
}
