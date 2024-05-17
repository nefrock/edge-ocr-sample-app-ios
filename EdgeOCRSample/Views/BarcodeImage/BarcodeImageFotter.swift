//
//  BarcodeImageFotter.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import os
import SwiftUI

struct BarcodeImageFotter: View {
    @Binding var image: UIImage
    var body: some View {
        VStack {
            Button(action: {
                // MARK: - バーコード画像をスキャン

                // NOTOE: エラーをオプショナル型に変換して，エラーメッセージを無視
                if let scannedImage = try? image.scanBarcodeImage() {
                    image = scannedImage
                }

            }, label: {
                Text("バーコードをスキャン")
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
    BarcodeImageFotter(image: .constant(UIImage(named: "sample_text")!))
}
