//
//  BoxOverlayView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct BoxesOverlayView: View {
    @Binding var aspectRatio: Double

    var body: some View {
        HostedBoxesOverlayViewController(aspectRatio: $aspectRatio)
            .ignoresSafeArea()
    }
}

#Preview {
    BoxesOverlayView(aspectRatio: .constant(1.0))
}
