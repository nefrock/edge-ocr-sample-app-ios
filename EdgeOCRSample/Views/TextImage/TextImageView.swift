//
//  ImageView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/15.
//

import EdgeOCRSwift
import Foundation
import SwiftUI

struct TextImageView: View {
    @State var image = UIImage(named: "sample_text")!
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width * 0.8,
                    height: UIScreen.main.bounds.height * 0.5)
            Spacer().frame(height: 30)
            TextImageFooter(image: $image)
        }
    }
}

#Preview {
    TextImageView()
}
