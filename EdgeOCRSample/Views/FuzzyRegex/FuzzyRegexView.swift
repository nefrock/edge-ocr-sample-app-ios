//
//  EditDistanceViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import Foundation
import SwiftUI

struct FuzzyRegexView: View {
    @Binding var aspectRatio: Double
    @State var showDialog: Bool = false
    @State var messages: [String] = []

    var body: some View {
        ZStack {
            HostedFuzzyRegexViewController(
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
    FuzzyRegexView(aspectRatio: .constant(1.0))
}
