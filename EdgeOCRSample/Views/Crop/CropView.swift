//
//  CropMainView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import Foundation
import SwiftUI

struct CropView: View {
    @State var cropHorizontalBias: CGFloat = 0.5
    @State var cropVerticalBias: CGFloat = 0.5
    @State var cropWidth: CGFloat = 1.0
    @State var cropHeight: CGFloat = 1.0

    var body: some View {
        VStack {
            HostedCropViewController(
                cropHorizontalBias: $cropHorizontalBias,
                cropVerticalBias: $cropVerticalBias,
                cropWidth: $cropWidth,
                cropHeight: $cropHeight
            ).ignoresSafeArea()

            HStack {
                VStack(spacing: 0) {
                    Text("X 座標")
                    Slider(value: $cropHorizontalBias, in: 0.0 ... 1.0, step: 0.01)
                }
                VStack(spacing: 0) {
                    Text("Y 座標")
                    Slider(value: $cropVerticalBias, in: 0.0 ... 1.0, step: 0.01)
                }
            }

            HStack {
                VStack(spacing: 0) {
                    Text("幅")
                    Slider(value: $cropWidth, in: 0.0 ... 1.0, step: 0.01)
                }
                VStack(spacing: 0) {
                    Text("高さ")
                    Slider(value: $cropHeight, in: 0.0 ... 1.0, step: 0.01)
                }
            }
        }
    }
}

#Preview {
    CropView()
}
