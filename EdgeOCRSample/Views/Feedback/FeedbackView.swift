//
//  FeedbackView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import SwiftUI

struct FeedbackView: View {
    @State var sendFlag: Bool = false
    var body: some View {
        VStack(spacing: 30) {
            HostedFeedbackViewController(sendFlag: $sendFlag)
                .ignoresSafeArea()
            FeedbackFotter(sendFlag: $sendFlag)
            Spacer().frame(height: 50)
        }
    }
}

#Preview {
    FeedbackView()
}
