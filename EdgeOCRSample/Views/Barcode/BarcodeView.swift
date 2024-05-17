//
//  BarcodeView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct BarcodeView: View {
    @Binding var aspectRatio: Double
    @State var showDialog: Bool = false
    @State var messages: [String] = []

    var body: some View {
        ZStack {
            HostedBarcodeViewController(
                aspectRatio: $aspectRatio,
                showDialog: $showDialog,
                messages: $messages
            ).ignoresSafeArea()

            if showDialog {
                DialogView(showDialog: $showDialog, messages: $messages)
            }
        }
    }
}

#Preview {
    BarcodeView(
        aspectRatio: .constant(1.0)
    )
}
