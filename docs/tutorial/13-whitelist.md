# ホワイトリスト（マスターデータ）

このチュートリアルでは，OCR 検出結果がホワイトリスト（マスターデータ）に含まれているテキストを検出した際に，ダイアログを表示する方法を説明いたします．


<img src="./imgs/13-whitelist/whitelist.jpeg" width="300">


## 概要
検出したいホワイトリストをあらかじめ定義し，検出結果のテキストがホワイトリストに含まれているかどうかを判定します．
そして，ホワイトリストに含まれているテキストを検出した場合には，ダイアログを表示します．

この例の実装は，
`EdgeOCRSample/Views/WhiteList/WhiteListViewController.swift` と
`EdgeOCRSample/Views/WhiteList/WhiteListView.swift`，
`EdgeOCRSample/Views/WhiteList/WhiteListAnalyzer.swift`，
`EdgeOCRSample/Views/Main/MainView.swift`，
に実装されていますので，ご参考になさってください．


## ホワイトリストの実装方法
`EdgeOCRSample/Views/WhiteList/WhiteListAnalyzer.swift` に実装されている `WhiteListAnalyzer` クラスを使用して，検出結果とホワイトリストの比較を行います．

ホワイトリストに含まれている `Detection<Text>` は `targetDetections` に，含まれていない `Detection<Text>` は `notTargetDetections` に格納します．

```swift
class AnalyzerResult {
    let targetDetections: [Detection<Text>]
    let notTargetDetections: [Detection<Text>]

    init(targetDetections: [Detection<Text>], notTargetDetections: [Detection<Text>]) {
        self.targetDetections = targetDetections
        self.notTargetDetections = notTargetDetections
    }

    func getTargetDetections() -> [Detection<Text>] {
        return targetDetections
    }

    func getNotTargetDetections() -> [Detection<Text>] {
        return notTargetDetections
    }
}

class WhiteListAnalyzer {
    let whiteList: Set = [
        "090-1234-5678",
        "090-0000-1234",
        "090-2222-3456",
        "090-4444-5555",
        "090-6666-7777",
        "090-8888-9999",
    ]

    init() {}

    func analyze(_ detections: [Detection<Text>]) -> AnalyzerResult {
        var targetDetections: [Detection<Text>] = []
        var notTargetDetections: [Detection<Text>] = []

        for detection in detections {
            let text = detection.getScanObject().getText()
            // ホワイトリストに含まれているかどうかを判定
            if whiteList.contains(text) {
                targetDetections.append(detection)
            } else {
                notTargetDetections.append(detection)
            }
        }

        return AnalyzerResult(
            targetDetections: targetDetections,
            notTargetDetections: notTargetDetections)
    }
}
```


次に，`EdgeOCRSample/Views/WhiteList/WhiteListViewController.swift` では，`WhiteListAnalyzer` クラスを使用して，検出結果とホワイトリストの比較を行います．

`targetDetection` はホワイトリストに含まれているテキストを，`notTargetDetection` はホワイトリストに含まれていないテキストを表します．

`targetDetection` は緑色の枠で，`notTargetDetection` は赤色の枠で表示されます．

```swift
func drawDetections(result: ScanResult) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    detectionLayer.sublayers = nil

    // MARK: - ホワイトリストに検出結果が含まれているかを判定

    let detections = result.getTextDetections()
    let analyzerResult = analyzer.analyze(detections)
    var messages: [String] = []
    for targetDetection in analyzerResult.getTargetDetections() {
        let text = targetDetection.getScanObject().getText()
        let bbox = targetDetection.getBoundingBox()
        drawDetection(bbox: bbox, text: text)
        messages.append(text)
    }

    for notTargetDetection in analyzerResult.getNotTargetDetections() {
        let text = notTargetDetection.getScanObject().getText()
        let bbox = notTargetDetection.getBoundingBox()
        drawDetection(bbox: bbox, text: text, boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
    }

    if messages.count > 0 {
        showDialog = true
        self.messages = messages
    }
    CATransaction.commit()
}
```