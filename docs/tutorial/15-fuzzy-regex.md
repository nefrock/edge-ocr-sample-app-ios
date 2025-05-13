# 正規表現を用いた検索（曖昧検索）

このチュートリアルでは，正規表現を用いた曖昧検索について説明します．

## 概要

検出結果のテキストに対して，正規表現を用いた検索を行うことができます．
正規表現とテキストのマッチングを行う際に，正規表現内に含まれる文字とテキスト内の文字が完全に一致しなくても，一定の許容範囲内でマッチングを行うことができます．

この例の実装は，
`EdgeOCRSample/Views/FuzzyRegex/FuzzyViewController.swift` と
`EdgeOCRSample/Views/FuzzyRegex/FuzzyRegexView.swift`，
`EdgeOCRSample/Views/FuzzyRegex/FuzzyRegexAnalyzer.swift`
に実装されていますので，ご参考になさってください．

## 正規表現を用いた検索（曖昧検索）の実装方法

`EdgeOCRSample/Views/FuzzyRegex/FuzzyRegexAnalyzer.swift` に実装されている `FuzzyRegexAnalyzer` クラスを使用して，検出結果と正規表現の比較を行います．
その際に，検出結果と正規表現に含まれている文字列とのマッチングを `FuzzyRegex` クラスを使用して，文字列間の距離が一定以下の場合に文字を検出します．

```swift
class FuzzyRegexAnalyzer {
    let fuzzyRegex = FuzzyRegex(pattern: #"[0-9]+-[0-9]+"#, fuzzyType: .NNDistance, threshold: 0.4)
    init() {}

    func analyze(_ detections: [Text]) -> AnalyzerResult {
        var targetDetections = [Text]()
        var notTargetDetections = [Text]()

        for detection in detections {
            var targetDetection: Text? = nil
            let text = detection.getText()
            let matched = fuzzyRegex.match(text)
            if !matched.isEmpty {
                detection.setText(matched)
                targetDetection = detection
            }
            if let targetDetection = targetDetection {
                targetDetections.append(targetDetection)
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

`FuzzyRegex` クラスでは，`FuzzyRegex` イニシャライザーで正規表現パターン，曖昧検索のタイプ，しきい値を指定します．
そして，`match` メソッドで検出結果と正規表現のマッチングを行います．

次に，`EdgeOCRSample/Views/FuzzyRegex/FuzzyViewController.swift` では，`FuzzyRegexAnalyzer` クラスを使用して，検出結果と正規表現の比較を行います．

`targetDetection` は正規表現とマッチしたテキストを，`notTargetDetection` は正規表現とマッチしなかったテキストを表します．

`targetDetections` は緑色の枠で囲まれたテキストを，`notTargetDetections` は赤色の枠で囲まれたテキストを表示します．

```swift
    func drawDetections(result: ScanResult) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionLayer.sublayers = nil

        // MARK: - 編集距離を許容して，ホワイトリストに検出結果が含まれているかを判定

        let detections = result.getTextDetections()
        let analyzerResult = analyzer.analyze(detections)
        var messages: [String] = []
        for targetDetection in analyzerResult.getTargetDetections() {
            let text = targetDetection.getText()
            let bbox = targetDetection.getBoundingBox()
            drawDetection(bbox: bbox, text: text)
            messages.append(text)
        }

        for notTargetDetection in analyzerResult.getNotTargetDetections() {
            let text = notTargetDetection.getText()
            let bbox = notTargetDetection.getBoundingBox()
            drawDetection(bbox: bbox,
                          text: text,
                          boxColor: UIColor.red.withAlphaComponent(0.5).cgColor)
        }

        if messages.count > 0 {
            showDialog = true
            self.messages = messages
        }
        CATransaction.commit()
    }
```

## 次のステップ（Optional）

次はDPMコードの読み取りについて説明します．

↪️ [AI を用いたDPMコードの読み取り（Optional）](16-dpm.md)
