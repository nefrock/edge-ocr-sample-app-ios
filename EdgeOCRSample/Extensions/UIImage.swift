//
//  UIImage.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import AVFoundation
import UIKit

extension UIImage {
    func drawBoundingBoxes(
        boundingBoxes: [CGRect],
        texts: [String],
        textColor: UIColor,
        boxColor: UIColor
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(at: .zero)
        let imageLength = self.size.width > self.size.height ? self.size.width : self.size.height
        let fontSize = imageLength * 0.03

        for (index, boundingBox) in boundingBoxes.enumerated() {
            let detectionResult = texts[index]
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.green.cgColor)
            context?.setLineWidth(5.0)
            context?.addRect(boundingBox)
            context?.strokePath()

            let textFontAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.backgroundColor: boxColor
            ]
            let detectionText = NSAttributedString(string: detectionResult, attributes: textFontAttributes)
            detectionText.draw(at: CGPoint(x: boundingBox.origin.x, y: boundingBox.origin.y))
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func fixImageRotation() -> UIImage {
        if self.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            self.draw(in: CGRect(origin: .zero, size: self.size))
            if let fixedImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return fixedImage
            }
            UIGraphicsEndImageContext()
        }
        return self
    }
}
