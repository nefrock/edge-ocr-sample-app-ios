//
//  SimpleTextView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct SimpleTextView: View {
    var body: some View {
        HostedSimpleTextViewController()
            .ignoresSafeArea()
    }
}

#Preview {
    SimpleTextView()
}
