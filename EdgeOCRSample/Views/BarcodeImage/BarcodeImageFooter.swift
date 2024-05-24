//
//  BarcodeImageFotter.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import os
import SwiftUI

struct BarcodeImageFooter: View {
    @Binding var image: UIImage
    var body: some View {
        VStack {
            Button(action: {
                // MARK: - バーコード画像をスキャン

                do {
                    if let scannedImage = try image.scanBarcodeImage() {
                        image = scannedImage
                    }
                } catch {
                    os_log(.error, log: .default, "error: %@", error.localizedDescription)
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
    BarcodeImageFooter(image: .constant(UIImage(named: "sample_text")!))
}
