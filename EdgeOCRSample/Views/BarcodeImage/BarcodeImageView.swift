//
//  BarcodeImage.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import EdgeOCRSwift
import Foundation
import SwiftUI

struct BarcodeImageView: View {
    @State var image = UIImage(named: "sample_barcode")!
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width * 0.8,
                    height: UIScreen.main.bounds.height * 0.5)
            Spacer().frame(height: 30)
            BarcodeImageFotter(image: $image)
        }
    }
}

#Preview {
    BarcodeImageView()
}
