//
//  DetectionFilterView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct DetectionFilterView: View {
    @Binding var aspectRatio: Double

    var body: some View {
        HostedDetectionFilterViewController(
            aspectRatio: $aspectRatio
        ).ignoresSafeArea()
    }
}

#Preview {
    DetectionFilterView(aspectRatio: .constant(1.0))
}
