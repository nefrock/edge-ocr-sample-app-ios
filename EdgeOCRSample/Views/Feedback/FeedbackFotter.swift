//
//  FeedbackFotter.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import os
import SwiftUI

struct FeedbackFotter: View {
    @Binding var sendFlag: Bool
    var body: some View {
        VStack {
            Button(action: {}, label: {
                Text("フィードバックを送信")
                    .font(.headline)
                    .bold()
            })
            .frame(width: 200, height: 50)
            .foregroundColor(.black)
            .background(Color.blue.opacity(0.3))
            .cornerRadius(10)
        }
    }
}

#Preview {
    FeedbackFotter(sendFlag: .constant(false))
}
