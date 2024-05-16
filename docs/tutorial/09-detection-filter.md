# テキスト範囲の検出時にフィルタを行う

このチュートリアルでは，検出されたテキストに対してフィルタリングする方法を説明いたします．


## 概要
EdgeOCRでは，テキスト範囲の検出 -> テキスト認識の流れで OCR を行っています．
そこで，テキスト範囲の検出で得られた各テキストの位置情報を利用して，
テキスト認識を行う前に検出されたテキストをフィルタリングすることができます．

検出されたテキスト範囲で `detectionFilter` クラスを継承し，`filter` メソッドを実装することで，
検出されたテキストをフィルタリングすることができます．

この例の実装は 
`EdgeOCRSample/Views/DetectionFilter/DetectionFilterViewController.swift` と　
`EdgeOCRSample/Views/DetectionFilter/DetectionFilterView.swift`
`EdgeOCRSample/Views/DetectionFilter/CenterDetectionFilter.swift`，
に実装されていますので，ご参考になさってください．


## テキストをフィルタリングする実装方法

`DetectionFilter` クラスを継承し，`filter` メソッドを実装します．
例えば，中心のみを検出するフィルタリングを行う場合は以下のように実装します．

```swift
class CenterDetectionFilter: DetectionFilter {
    override func filter(_ detections: [Detection<Text>]) -> [Detection<Text>] {
        var filterd_detections: [Detection<Text>] = []
        if detections.count > 0 {
            var most_centered_box = detections[0]
            var distanceFromCenter = 100.0
            for detection in detections {
                let dist = self.calcDistanceFromCenter(detection: detection)
                if dist < distanceFromCenter {
                    distanceFromCenter = dist
                    most_centered_box = detection
                }
            }
            filterd_detections.append(most_centered_box)
        }
        return filterd_detections
    }

    private func calcDistanceFromCenter(detection: Detection<Text>) -> CGFloat {
        let bbox = detection.getBoundingBox()
        let top = bbox.minY
        let left = bbox.minX
        let bottom = bbox.maxY
        let right = bbox.maxX
        let boxCenterX = left + 0.5 * (right - left)
        let boxCenterY = top + 0.5 * (bottom - top)

        let a = 0.5 - boxCenterX
        let b = 0.5 - boxCenterY
        return a * a + b * b
    }
}

```

`DetectionFilter` クラスを継承し，`filter` メソッドを実装することで，検出されたテキストをフィルタリングすることができます．
画像内に対して検出されたテキストの範囲の配列が引数として渡されるので，このリストを加工して返すことでフィルタを実現します．
テキストの範囲を `Detection<Text>` として取得し，フィルタの実装を行います．
文字情報の読み取りはまだ行われていないので，`ScanObject` の情報は利用できない点にご注意ください．


作成したフィルタをEdgeOCRに設定するには，`setDetectionFilter` メソッドを用います．
```swift
// MARK: 検出結果をフィルタリングする例の実装
Button(action: {
    let modelSettings = ModelSettings()
    modelSettings.setDetectionFilter(CenterDetectionFilter())
    loadModelAndNavigate(destination: .detectionFilterView, modelSettings: modelSettings)
}) {
    Text("検出結果をフィルタリング")
}
```
