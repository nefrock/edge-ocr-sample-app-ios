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
        VStack {
            HostedFeedbackViewController(sendFlag: $sendFlag)
                .ignoresSafeArea()
            Spacer().frame(height: 20)
            FeedbackFooter(sendFlag: $sendFlag)
            Spacer().frame(height: 20)
        }
    }
}

#Preview {
    FeedbackView()
}
