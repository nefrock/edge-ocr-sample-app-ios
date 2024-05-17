//
//  NTimesScanView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct NTimesScanView: View {
    @Binding var aspectRatio: Double

    var body: some View {
        HostedNTimesScanViewController(aspectRatio: $aspectRatio)
            .ignoresSafeArea()
    }
}

#Preview {
    NTimesScanView(aspectRatio: .constant(1.0))
}
