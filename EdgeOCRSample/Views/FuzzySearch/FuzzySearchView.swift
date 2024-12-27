//
//  EditDistanceViewController.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/14.
//

import Foundation
import SwiftUI

struct FuzzySearchView: View {
    @Binding var aspectRatio: Double
    @State var showDialog: Bool = false
    @State var messages: [String] = []

    var body: some View {
        ZStack {
            HostedFuzzySearchViewController(
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
    FuzzySearchView(aspectRatio: .constant(1.0))
}
