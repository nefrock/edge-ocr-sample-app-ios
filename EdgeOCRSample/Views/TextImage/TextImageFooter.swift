//
//  TextImageFotter.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import EdgeOCRSwift
import Foundation
import os
import SwiftUI

struct TextImageFooter: View {
    @Binding var image: UIImage
    var body: some View {
        VStack {
            Button(action: {
                // MARK: - テキスト画像スキャン

                do {
                    // get the documents directory url
                    let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    // choose a name for your image
                    let fileName = "image.jpg"
                    // create the destination file url to save your image
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    // get your UIImage jpeg data representation and check if the destination file url already exists
                    if let data = image.jpegData(compressionQuality: 1),
                       !FileManager.default.fileExists(atPath: fileURL.path)
                    {
                        // writes the image data to disk
                        try data.write(to: fileURL)
                        os_log("file saved", type: .debug)
                    }

                } catch {
                    os_log("error: %@", type: .error, error.localizedDescription)
                }

                // NOTOE: エラーをオプショナル型に変換して，エラーメッセージを無視
                if let scannedImage = try? image.scanTextImage() {
                    image = scannedImage
                }

            }, label: {
                Text("テキストをスキャン")
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
    TextImageFooter(image: .constant(UIImage(named: "sample_text")!))
}
