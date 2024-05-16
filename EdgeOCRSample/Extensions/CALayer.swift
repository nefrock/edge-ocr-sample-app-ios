//
//  CALayer.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/05/16.
//

import AVFoundation
import UIKit

extension CALayer {
    func addCenterPoint(color: CGColor, radius: CGFloat) {
        // CALayerの中心座標を取得します
        let centerX = self.bounds.midX
        let centerY = self.bounds.midY

        // 点の描画
        let dotLayer = CAShapeLayer()
        dotLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: centerX, y: centerY),
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true).cgPath
        dotLayer.fillColor = color

        // CALayerに点を追加します
        self.addSublayer(dotLayer)
    }
}
