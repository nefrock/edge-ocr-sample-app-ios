//
//  WhiteListView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/08.
//

import Foundation
import SwiftUI

struct WhiteListView: View {
    @Binding var aspectRatio: Double
    @State var showDialog: Bool = false
    @State var messages: [String] = []

    var body: some View {
        ZStack {
            HostedWhiteListViewController(aspectRatio: $aspectRatio,
                                          showDialog: $showDialog,
                                          messages: $messages)
                .ignoresSafeArea()

            if showDialog {
                DialogView(showDialog: $showDialog, messages: $messages)
            }
        }
    }
}

#Preview {
    WhiteListView(aspectRatio: .constant(1.0))
}
